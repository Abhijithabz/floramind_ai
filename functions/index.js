const { defineSecret } = require("firebase-functions/params");
const { onCall, HttpsError } = require("firebase-functions/v2/https");

const geminiApiKey = defineSecret("GEMINI_API_KEY");
const openaiApiKey = defineSecret("OPENAI_API_KEY");
const maxImageBytes = 7 * 1024 * 1024;
const geminiModel = "gemini-3.6-flash";

function mimeTypeFor(fileName) {
  const extension = fileName.toLowerCase().split(".").pop();
  if (extension === "png") return "image/png";
  if (extension === "webp") return "image/webp";
  if (extension === "jpg" || extension === "jpeg") return "image/jpeg";
  throw new HttpsError("invalid-argument", "Unsupported image type.");
}

function unknownResponse() {
  return {
    success: false,
    plantName: "Unknown Plant",
    scientificName: "Unknown",
    confidence: 0,
    description: "",
    careTips: [],
    alternatives: [],
    plant: {
      common_name: "Unknown Plant",
      scientific_name: "Unknown",
      family: "Unknown",
      genus: "Unknown",
      confidence: 0,
    },
  };
}

function normalizedResponse(plant) {
  const plantName = typeof plant.plantName === "string" && plant.plantName.trim()
    ? plant.plantName.trim()
    : "Unknown Plant";
  const scientificName = typeof plant.scientificName === "string" &&
    plant.scientificName.trim() ? plant.scientificName.trim() : "Unknown";
  const confidence = Number(plant.confidence);
  const safeConfidence = Number.isFinite(confidence)
    ? Math.min(1, Math.max(0, confidence))
    : 0;
  const isUnknown = plantName === "Unknown Plant" || safeConfidence <= 0;

  if (isUnknown) return unknownResponse();

  const careTips = Array.isArray(plant.careTips)
    ? plant.careTips.filter((tip) => typeof tip === "string").slice(0, 5)
    : [];
  const description = typeof plant.description === "string"
    ? plant.description.trim()
    : "";

  return {
    success: true,
    plantName,
    scientificName,
    confidence: Number(safeConfidence.toFixed(4)),
    description,
    careTips,
    alternatives: [],
    plant: {
      common_name: plantName,
      scientific_name: scientificName,
      family: "Unknown",
      genus: "Unknown",
      confidence: Number(safeConfidence.toFixed(4)),
    },
  };
}

exports.identifyPlant = onCall({
  secrets: [geminiApiKey],
  timeoutSeconds: 90,
  memory: "256MiB",
}, async (request) => {
  const data = request.data || {};
  const imageBase64 = data.imageBase64;
  const fileName = typeof data.fileName === "string" && data.fileName.trim()
    ? data.fileName.trim()
    : "plant-image.jpg";

  if (typeof imageBase64 !== "string" || !imageBase64) {
    throw new HttpsError("invalid-argument", "No image was provided.");
  }

  const imageBytes = Buffer.from(imageBase64, "base64");
  if (!imageBytes.length || imageBytes.length > maxImageBytes) {
    throw new HttpsError("invalid-argument", "The image is empty or too large.");
  }

  const prompt = [
    "Analyze this image specifically as a plant and flower identification task.",
    "Identify the most likely plant or flower and provide its common name.",
    "Provide a scientific name only when reasonably confident; do not invent one.",
    "Estimate confidence as a number from 0 to 1.",
    "If the image is unclear or is not a plant, use Unknown Plant and confidence 0.",
    "Return only JSON matching the requested schema, with no markdown or unrelated explanation.",
  ].join(" ");

  const body = {
    contents: [{
      parts: [
        {
          inlineData: {
            mimeType: mimeTypeFor(fileName),
            data: imageBase64,
          },
        },
        { text: prompt },
      ],
    }],
    generationConfig: {
      responseMimeType: "application/json",
      responseSchema: {
        type: "OBJECT",
        properties: {
          plantName: { type: "STRING" },
          scientificName: { type: "STRING" },
          confidence: { type: "NUMBER" },
          description: { type: "STRING" },
          careTips: {
            type: "ARRAY",
            items: { type: "STRING" },
          },
        },
        required: ["plantName", "scientificName", "confidence", "description", "careTips"],
      },
    },
  };

  let response;
  try {
    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent`;
    response = await fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": geminiApiKey.value(),
      },
      body: JSON.stringify(body),
    });
  } catch (error) {
    console.error("Gemini request failed", error);
    throw new HttpsError("unavailable", "Gemini is unavailable right now.");
  }

  if (response.status === 401 || response.status === 403) {
    throw new HttpsError("internal", "Gemini authentication failed.");
  }
  if (response.status === 429) {
    throw new HttpsError("resource-exhausted", "Gemini rate limit reached.");
  }
  if (!response.ok) {
    console.error("Gemini returned status", response.status);
    throw new HttpsError("unavailable", "Gemini rejected the image request.");
  }

  let payload;
  try {
    payload = await response.json();
  } catch (error) {
    throw new HttpsError("internal", "Gemini returned an unexpected response.");
  }

  const text = payload.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string" || !text.trim()) {
    return unknownResponse();
  }

  try {
    return normalizedResponse(JSON.parse(text));
  } catch (error) {
    console.error("Gemini returned invalid structured output");
    throw new HttpsError("internal", "Gemini returned invalid identification data.");
  }
});

exports.generateCultivationTips = onCall({
  secrets: [openaiApiKey],
  timeoutSeconds: 30,
  memory: "256MiB",
}, async (request) => {
  const data = request.data || {};
  const fields = ["plant", "category", "temperature", "exposure", "soil", "ph", "watering", "spacing", "stage"];
  const values = Object.fromEntries(fields.map((field) => [
    field,
    typeof data[field] === "string" ? data[field].trim().slice(0, 160) : "not provided",
  ]));

  if (values.plant === "not provided") {
    throw new HttpsError("invalid-argument", "A plant or crop is required.");
  }

  const prompt = [
    "Give practical cultivation tips for the selected crop or flowering plant.",
    "Use the supplied growing information, avoid inventing exact pesticide or fertilizer doses, and return only JSON.",
    `Plant: ${values.plant}; category: ${values.category}; temperature: ${values.temperature}; exposure: ${values.exposure}; soil: ${values.soil}; pH: ${values.ph}; watering: ${values.watering}; spacing: ${values.spacing}; stage: ${values.stage}.`,
  ].join(" ");

  let response;
  try {
    response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${openaiApiKey.value()}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        temperature: 0.2,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: "You are a careful agricultural education assistant." },
          { role: "user", content: prompt },
        ],
      }),
    });
  } catch (error) {
    console.error("OpenAI cultivation request failed", error);
    throw new HttpsError("unavailable", "Cultivation tips are unavailable right now.");
  }

  if (response.status === 401 || response.status === 403) {
    throw new HttpsError("internal", "OpenAI authentication failed.");
  }
  if (response.status === 429) {
    throw new HttpsError("resource-exhausted", "OpenAI rate limit reached.");
  }
  if (!response.ok) {
    console.error("OpenAI returned status", response.status);
    throw new HttpsError("unavailable", "OpenAI rejected the cultivation request.");
  }

  const payload = await response.json();
  const text = payload.choices?.[0]?.message?.content;
  if (typeof text !== "string" || !text.trim()) {
    throw new HttpsError("internal", "OpenAI returned no cultivation tips.");
  }

  try {
    const parsed = JSON.parse(text);
    const tips = Array.isArray(parsed.tips)
      ? parsed.tips.filter((tip) => typeof tip === "string").slice(0, 8)
      : [];
    if (!tips.length) throw new Error("No tips");
    return { success: true, tips, source: "OpenAI" };
  } catch (error) {
    throw new HttpsError("internal", "OpenAI returned invalid cultivation data.");
  }
});
