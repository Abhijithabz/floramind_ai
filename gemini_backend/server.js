const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");

// Local development may keep provider values in the existing Python backend
// env file. Render supplies these values directly as process environment vars.
function loadLocalProviderEnv() {
  const allowedKeys = new Set([
    "GEMINI_API_KEY",
    "PLANTNET_API_KEY",
    "PLANTNET_API_BASE_URL",
    "PLANTNET_PROJECT",
    "PLANTNET_LANG",
    "PLANTNET_RESULTS",
    "PLANTNET_CONFIDENCE_THRESHOLD",
  ]);
  const files = [path.join(__dirname, ".env"), path.join(__dirname, "..", "backend", ".env")];
  for (const file of files) {
    if (!fs.existsSync(file)) continue;
    for (const line of fs.readFileSync(file, "utf8").split(/\r?\n/)) {
      const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
      if (!match || !allowedKeys.has(match[1]) || process.env[match[1]]) continue;
      const value = match[2].replace(/^['"]|['"]$/g, "").trim();
      if (value && !value.startsWith("your_") && !value.endsWith("_here")) {
        process.env[match[1]] = value;
      }
    }
  }
}

loadLocalProviderEnv();

const port = process.env.PORT || 8080;
const host = "0.0.0.0";
const maxImageBytes = 7 * 1024 * 1024;
const maxRequestBytes = 12 * 1024 * 1024;
const requestWindowMs = 10 * 60 * 1000;
const maxRequestsPerWindow = 20;
const requestCounts = new Map();
const geminiModel = process.env.GEMINI_MODEL || "gemini-2.5-flash";
const plantNetBaseUrl = (process.env.PLANTNET_API_BASE_URL || "https://my-api.plantnet.org").replace(/\/$/, "");
const plantNetProject = process.env.PLANTNET_PROJECT || "all";
const plantNetLanguage = process.env.PLANTNET_LANG || "en";
const plantNetResults = Number(process.env.PLANTNET_RESULTS || 5);
const plantNetThreshold = Number(process.env.PLANTNET_CONFIDENCE_THRESHOLD || 0.3);
const providerTimeoutMs = 15000;

async function fetchWithTimeout(url, options = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), providerTimeoutMs);
  try {
    return await fetch(url, { ...options, signal: controller.signal });
  } catch (error) {
    if (error.name === "AbortError") {
      throw new Error("The plant identification provider timed out.");
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

function sendJson(response, statusCode, body) {
  response.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
  });
  response.end(JSON.stringify(body));
}

function unknownResponse(message = "No plant identification was found.") {
  return {
    success: false,
    message,
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

function clientIp(request) {
  const forwarded = request.headers["x-forwarded-for"];
  return typeof forwarded === "string"
    ? forwarded.split(",")[0].trim()
    : request.socket.remoteAddress || "unknown";
}

function isRateLimited(request) {
  const now = Date.now();
  const ip = clientIp(request);
  const entry = requestCounts.get(ip);
  if (!entry || now - entry.startedAt >= requestWindowMs) {
    requestCounts.set(ip, { startedAt: now, count: 1 });
    return false;
  }
  entry.count += 1;
  return entry.count > maxRequestsPerWindow;
}

function readRequestBody(request) {
  return new Promise((resolve, reject) => {
    let body = "";
    request.setEncoding("utf8");
    request.on("data", (chunk) => {
      body += chunk;
      if (Buffer.byteLength(body, "utf8") > maxRequestBytes) {
        reject(new Error("Request body is too large."));
        request.destroy();
      }
    });
    request.on("end", () => resolve(body));
    request.on("error", reject);
  });
}

function mimeTypeFor(fileName) {
  const extension = fileName.toLowerCase().split(".").pop();
  if (extension === "png") return "image/png";
  if (extension === "webp") return "image/webp";
  if (extension === "jpg" || extension === "jpeg") return "image/jpeg";
  return null;
}

function normalizeConfidence(value) {
  const confidence = Number(value);
  if (!Number.isFinite(confidence)) return 0;
  return Number(Math.min(1, Math.max(0, confidence)).toFixed(4));
}

function plantNetConfigured() {
  return Boolean(process.env.PLANTNET_API_KEY?.trim());
}

async function identifyWithPlantNet(imageBytes, fileName, mimeType, organ = "flower") {
  const apiKey = process.env.PLANTNET_API_KEY?.trim();
  if (!apiKey) throw new Error("PlantNet API key is not configured on the backend.");

  const endpoint = new URL(`${plantNetBaseUrl}/v2/identify/${plantNetProject}`);
  endpoint.searchParams.set("api-key", apiKey);
  endpoint.searchParams.set("lang", plantNetLanguage);
  endpoint.searchParams.set("nb-results", String(plantNetResults));
  endpoint.searchParams.set("detailed", "true");
  endpoint.searchParams.set("no-reject", "true");

  const form = new FormData();
  form.append("organs", ["flower", "leaf", "fruit", "bark", "habit"].includes(organ) ? organ : "flower");
  form.append("images", new Blob([imageBytes], { type: mimeType }), fileName);

  let response;
  try {
    response = await fetchWithTimeout(endpoint, { method: "POST", body: form });
  } catch (_) {
    throw new Error("PlantNet is unavailable or timed out right now.");
  }
  if (response.status === 401 || response.status === 403) throw new Error("PlantNet authentication failed.");
  if (response.status === 429) throw new Error("PlantNet rate limit reached.");
  if (!response.ok) {
    const detail = (await response.text()).replace(/\s+/g, " ").trim().slice(0, 180);
    throw new Error(`PlantNet rejected the image request (HTTP ${response.status}${detail ? `: ${detail}` : ""}).`);
  }

  const payload = await response.json();
  const results = Array.isArray(payload.results) ? payload.results : [];
  const top = results[0];
  const species = top?.species || {};
  const confidence = normalizeConfidence(top?.score);
  if (!top || confidence < plantNetThreshold) return unknownResponse("PlantNet could not identify this plant confidently.");

  const commonNames = Array.isArray(species.commonNames) ? species.commonNames : [];
  const scientificName = species.scientificNameWithoutAuthor || species.scientificName || "Unknown";
  return {
    success: true,
    message: "Plant identified by PlantNet.",
    plantName: commonNames[0] || scientificName,
    scientificName,
    confidence,
    description: "",
    careTips: [],
    alternatives: results.slice(1, 5).map((candidate) => {
      const candidateSpecies = candidate.species || {};
      const names = Array.isArray(candidateSpecies.commonNames) ? candidateSpecies.commonNames : [];
      return {
        common_name: names[0] || candidateSpecies.scientificNameWithoutAuthor || "Unknown",
        scientific_name: candidateSpecies.scientificNameWithoutAuthor || candidateSpecies.scientificName || "Unknown",
        confidence: normalizeConfidence(candidate.score),
      };
    }),
    plant: {
      common_name: commonNames[0] || scientificName,
      scientific_name: scientificName,
      family: species.family?.scientificNameWithoutAuthor || species.family?.scientificName || "Unknown",
      genus: species.genus?.scientificNameWithoutAuthor || species.genus?.scientificName || "Unknown",
      confidence,
    },
  };
}

function normalizeGeminiResponse(value) {
  const plantName = typeof value.plantName === "string" && value.plantName.trim() ? value.plantName.trim() : "Unknown Plant";
  const scientificName = typeof value.scientificName === "string" && value.scientificName.trim() ? value.scientificName.trim() : "Unknown";
  const confidence = normalizeConfidence(value.confidence);
  if (plantName === "Unknown Plant" || confidence <= 0) return unknownResponse("Gemini could not identify this plant confidently.");
  return {
    success: true,
    message: "Plant identified by Gemini.",
    plantName,
    scientificName,
    confidence,
    description: typeof value.description === "string" ? value.description.trim() : "",
    careTips: Array.isArray(value.careTips) ? value.careTips.filter((tip) => typeof tip === "string").slice(0, 5) : [],
    alternatives: [],
    plant: { common_name: plantName, scientific_name: scientificName, family: "Unknown", genus: "Unknown", confidence },
  };
}

async function identifyWithGemini(imageBase64, mimeType) {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) throw new Error("Gemini API key is not configured on the backend.");
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent`;
  const response = await fetchWithTimeout(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
    body: JSON.stringify({
      contents: [{ parts: [
        { inlineData: { mimeType, data: imageBase64 } },
        { text: "Identify the plant or flower in this image. Return only JSON with plantName, scientificName, confidence from 0 to 1, description, and careTips. Use confidence 0 if the image is not a plant or is unclear." },
      ] }],
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: {
          type: "OBJECT",
          properties: {
            plantName: { type: "STRING" },
            scientificName: { type: "STRING" },
            confidence: { type: "NUMBER" },
            description: { type: "STRING" },
            careTips: { type: "ARRAY", items: { type: "STRING" } },
          },
          required: ["plantName", "scientificName", "confidence", "description", "careTips"],
        },
      },
    }),
  });
  if (response.status === 401 || response.status === 403) throw new Error("Gemini authentication failed.");
  if (response.status === 429) throw new Error("Gemini rate limit reached.");
  if (response.status === 503) throw new Error("Gemini service is temporarily overloaded.");
  if (!response.ok) throw new Error("Gemini rejected the image request.");
  const payload = await response.json();
  const text = payload.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string" || !text.trim()) return unknownResponse();
  try {
    return normalizeGeminiResponse(JSON.parse(text));
  } catch (_) {
    throw new Error("Gemini returned invalid identification data.");
  }
}

async function recommendFertilizer(body) {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) throw new Error("Gemini API key is not configured on the backend.");

  const fields = ["plant", "stage", "condition", "soil", "npk"];
  const values = Object.fromEntries(fields.map((field) => [field, typeof body[field] === "string" ? body[field].trim().slice(0, 120) : ""]));
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent`;
  const response = await fetchWithTimeout(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
    body: JSON.stringify({
      contents: [{ parts: [{ text: `Give safe, general fertilizer guidance for this garden plant. Inputs: plant=${values.plant}; growth stage=${values.stage}; condition=${values.condition}; soil=${values.soil}; soil NPK=${values.npk || "not provided"}. Do not invent an exact dose. Return only JSON.` }] }],
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: {
          type: "OBJECT",
          properties: {
            summary: { type: "STRING" },
            npk: { type: "STRING" },
            application: { type: "STRING" },
            cautions: { type: "ARRAY", items: { type: "STRING" } },
          },
          required: ["summary", "npk", "application", "cautions"],
        },
      },
    }),
  });
  if (response.status === 401 || response.status === 403) throw new Error("Gemini authentication failed.");
  if (response.status === 429) throw new Error("Gemini rate limit reached.");
  if (response.status === 503) throw new Error("Gemini service is temporarily overloaded.");
  if (!response.ok) throw new Error("Gemini fertilizer recommendation failed.");
  const payload = await response.json();
  const text = payload.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string" || !text.trim()) throw new Error("Gemini returned no fertilizer guidance.");
  const recommendation = JSON.parse(text);
  return {
    success: true,
    summary: typeof recommendation.summary === "string" ? recommendation.summary : "Use a soil-test-based fertilizer.",
    npk: typeof recommendation.npk === "string" ? recommendation.npk : "Follow the product label.",
    application: typeof recommendation.application === "string" ? recommendation.application : "Apply according to the product label.",
    cautions: Array.isArray(recommendation.cautions) ? recommendation.cautions.filter((item) => typeof item === "string").slice(0, 5) : [],
    source: "Gemini",
  };
}

async function identifyPlant(body) {
  const imageBase64 = body.imageBase64;
  const fileName = typeof body.fileName === "string" && body.fileName.trim() ? body.fileName.trim() : "plant-image.jpg";
  const mimeType = mimeTypeFor(fileName);
  if (typeof imageBase64 !== "string" || !imageBase64 || !mimeType) throw new Error("A supported plant image is required.");
  const imageBytes = Buffer.from(imageBase64, "base64");
  if (!imageBytes.length || imageBytes.length > maxImageBytes) throw new Error("The image is empty or too large.");

  let geminiError = null;
  try {
    const result = await identifyWithGemini(imageBase64, mimeType);
    if (result.success) {
      console.log("Gemini identification succeeded.");
      return result;
    }
    geminiError = result.message || "Gemini returned no confident result.";
  } catch (error) {
    geminiError = error.message;
    console.warn(`Gemini failed; trying PlantNet fallback: ${geminiError}`);
  }

  let plantNetError = null;
  if (plantNetConfigured()) {
    try {
      const result = await identifyWithPlantNet(imageBytes, fileName, mimeType, body.organ || "flower");
      if (result.success) {
        console.log("PlantNet identification succeeded.");
        return result;
      }
      plantNetError = result.message || "PlantNet returned no confident result.";
    } catch (error) {
      plantNetError = error.message;
      console.warn(`PlantNet fallback failed: ${plantNetError}`);
    }
  }

  if (plantNetError) {
    throw new Error(`Gemini failed: ${geminiError} PlantNet failed: ${plantNetError}`);
  }
  throw new Error(`Gemini failed: ${geminiError} PlantNet is not configured.`);
}

const server = http.createServer(async (request, response) => {
  if (request.method === "GET" && request.url === "/health") {
    sendJson(response, 200, { ok: true, geminiConfigured: Boolean(process.env.GEMINI_API_KEY?.trim()), plantNetConfigured: plantNetConfigured() });
    return;
  }
  if (request.method === "OPTIONS") {
    response.writeHead(204, { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "Content-Type" });
    response.end();
    return;
  }
  if (request.method !== "POST" || request.url !== "/identifyPlant") {
    if (request.method === "POST" && request.url === "/fertilizerRecommendation") {
      if (isRateLimited(request)) {
        sendJson(response, 429, { success: false, message: "Too many requests. Please try again later." });
        return;
      }
      try {
        const rawBody = await readRequestBody(request);
        const body = JSON.parse(rawBody);
        sendJson(response, 200, await recommendFertilizer(body));
      } catch (error) {
        console.error("Fertilizer recommendation request failed:", error.message);
        const status = error.message.includes("API key is not configured") ? 503 : error.message.includes("rate limit") ? 429 : 502;
        sendJson(response, status, { success: false, message: error.message });
      }
      return;
    }
    sendJson(response, 404, { success: false, message: "Not found." });
    return;
  }
  if (isRateLimited(request)) {
    sendJson(response, 429, { success: false, message: "Too many identification requests. Please try again later.", alternatives: [] });
    return;
  }
  try {
    const rawBody = await readRequestBody(request);
    let body;
    try { body = JSON.parse(rawBody); } catch (_) { throw new Error("Invalid JSON request."); }
    sendJson(response, 200, await identifyPlant(body));
  } catch (error) {
    console.error("Plant identification request failed:", error.message);
    const status = error.message.includes("API key is not configured") ? 503 : error.message.includes("rate limit") ? 429 : 502;
    sendJson(response, status, { success: false, message: error.message, alternatives: [] });
  }
});

setInterval(() => {
  const now = Date.now();
  for (const [ip, entry] of requestCounts) if (now - entry.startedAt >= requestWindowMs) requestCounts.delete(ip);
}, requestWindowMs).unref();

server.listen(port, host, () => {
  console.log(`FloraMind Gemini + PlantNet backend listening on ${host}:${port}`);
});
