from __future__ import annotations

import argparse
import os
import re
from pathlib import Path
from typing import Any
from urllib.parse import quote_plus

import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")


PLANTS: list[dict[str, Any]] = [
    {
        "id": "rose",
        "commonName": "Rose",
        "scientificName": "Rosa",
        "category": "Flowering Shrub",
        "aliases": ["garden rose", "rose bush"],
        "description": "Classic flowering shrub with fragrant blooms.",
    },
    {
        "id": "hibiscus",
        "commonName": "Hibiscus",
        "scientificName": "Hibiscus rosa-sinensis",
        "category": "Flowering Shrub",
        "aliases": ["china rose"],
        "description": "Tropical flowering shrub with large colorful flowers.",
    },
    {
        "id": "jasmine",
        "commonName": "Jasmine",
        "scientificName": "Jasminum sambac",
        "category": "Flowering Vine",
        "aliases": ["arabian jasmine", "malli"],
        "description": "Fragrant climber prized for white blooms.",
    },
    {
        "id": "marigold",
        "commonName": "Marigold",
        "scientificName": "Tagetes erecta",
        "category": "Annual Flower",
        "aliases": ["african marigold"],
        "description": "Bright annual flower often used along borders and beds.",
    },
    {
        "id": "orchid",
        "commonName": "Orchid",
        "scientificName": "Orchidaceae",
        "category": "Ornamental",
        "aliases": ["moth orchid"],
        "description": "Elegant bloom with sensitive roots and humidity needs.",
    },
    {
        "id": "peace-lily",
        "commonName": "Peace Lily",
        "scientificName": "Spathiphyllum wallisii",
        "category": "Indoor Plant",
        "aliases": ["spathiphyllum"],
        "description": "Shade-loving houseplant with glossy leaves and white spathes.",
    },
    {
        "id": "pothos",
        "commonName": "Pothos",
        "scientificName": "Epipremnum aureum",
        "category": "Indoor Vine",
        "aliases": ["money plant", "devil's ivy"],
        "description": "Easy-care trailing vine for homes and offices.",
    },
    {
        "id": "snake-plant",
        "commonName": "Snake Plant",
        "scientificName": "Dracaena trifasciata",
        "category": "Indoor Plant",
        "aliases": ["sansevieria"],
        "description": "Tough upright plant that tolerates low light and infrequent watering.",
    },
]


DISEASES: list[dict[str, Any]] = [
    {
        "name": "Black Spot",
        "plantId": "rose",
        "severity": "high",
        "symptoms": [
            "Black or dark brown spots with yellow halos on leaves",
            "Lower leaves yellowing and dropping early",
            "Reduced flowering and weaker growth",
        ],
        "causes": [
            "Wet foliage and overhead watering",
            "Poor airflow around the canopy",
            "Infected fallen leaves left on the soil",
        ],
        "remedies": [
            "Remove spotted leaves and clean up debris",
            "Water at the base instead of splashing the foliage",
            "Apply a rose-safe fungicide if the infection spreads",
        ],
        "prevention": [
            "Space roses for airflow",
            "Mulch and water early in the day",
            "Remove fallen leaves regularly",
        ],
        "imageText": "Rose Black Spot",
    },
    {
        "name": "Powdery Mildew",
        "plantId": "rose",
        "severity": "high",
        "symptoms": [
            "White powdery coating on leaves, stems, or buds",
            "Curled or distorted foliage",
            "Slow, weak new growth",
        ],
        "causes": [
            "Humid weather with poor air circulation",
            "Crowded plants in shaded corners",
            "Spores spreading through wind and touch",
        ],
        "remedies": [
            "Remove heavily affected growth",
            "Improve light and airflow around the plant",
            "Use a suitable fungicidal spray if needed",
        ],
        "prevention": [
            "Avoid overcrowding roses",
            "Water at the base and not overhead",
            "Inspect new plants before mixing them in",
        ],
        "imageText": "Rose Powdery Mildew",
    },
    {
        "name": "Leaf Spot",
        "plantId": "hibiscus",
        "severity": "moderate",
        "symptoms": [
            "Brown or black circular spots on leaves",
            "Yellow halos around lesions",
            "Premature leaf drop in severe cases",
        ],
        "causes": [
            "Wet leaves from overhead watering",
            "Warm, humid weather",
            "Pathogens surviving in old debris",
        ],
        "remedies": [
            "Remove infected leaves and fallen debris",
            "Avoid splashing water onto the canopy",
            "Apply a fungicide if new spots continue appearing",
        ],
        "prevention": [
            "Water at the soil line",
            "Keep the plant area clean",
            "Provide enough spacing for airflow",
        ],
        "imageText": "Hibiscus Leaf Spot",
    },
    {
        "name": "Powdery Mildew",
        "plantId": "jasmine",
        "severity": "moderate",
        "symptoms": [
            "White dusty film on leaves and buds",
            "Distorted or curled new growth",
            "Slower blooming and weaker shoots",
        ],
        "causes": [
            "Shady conditions with high humidity",
            "Poor airflow within the vine",
            "Damp leaves during warm nights",
        ],
        "remedies": [
            "Prune dense growth to open the canopy",
            "Improve sun exposure and circulation",
            "Treat with neem or a fungicide if needed",
        ],
        "prevention": [
            "Water early and avoid wetting leaves",
            "Train the vine with room to breathe",
            "Inspect the plant regularly",
        ],
        "imageText": "Jasmine Powdery Mildew",
    },
    {
        "name": "Powdery Mildew",
        "plantId": "marigold",
        "severity": "moderate",
        "symptoms": [
            "Fine white coating on leaves and stems",
            "Faded or curled foliage",
            "Reduced vigor in flowering plants",
        ],
        "causes": [
            "Overcrowded beds with poor airflow",
            "Warm days and cool, damp nights",
            "Spores lingering on plant debris",
        ],
        "remedies": [
            "Remove affected foliage",
            "Space plants and open the canopy",
            "Use a mildew treatment if the spread continues",
        ],
        "prevention": [
            "Avoid crowding seedlings and transplants",
            "Keep beds clean and well ventilated",
            "Water at the base of the plant",
        ],
        "imageText": "Marigold Powdery Mildew",
    },
    {
        "name": "Root Rot",
        "plantId": "orchid",
        "severity": "critical",
        "symptoms": [
            "Mushy roots or blackened root tips",
            "Wilting even when the potting mix is wet",
            "Yellowing leaves and plant collapse",
        ],
        "causes": [
            "Overwatering and waterlogged media",
            "Poor drainage in the container",
            "Old, compacted potting mix",
        ],
        "remedies": [
            "Trim rotten roots and repot into fresh medium",
            "Reduce watering immediately",
            "Discard heavily damaged sections if needed",
        ],
        "prevention": [
            "Use a free-draining orchid mix",
            "Empty saucers after watering",
            "Water only when roots start drying",
        ],
        "imageText": "Orchid Root Rot",
    },
    {
        "name": "Bacterial Soft Rot",
        "plantId": "orchid",
        "severity": "high",
        "symptoms": [
            "Water-soaked spots that turn mushy quickly",
            "Foul-smelling tissue collapse",
            "Rapid spread across leaves or crowns",
        ],
        "causes": [
            "Warm, wet conditions",
            "Contaminated tools or hands",
            "Water sitting in leaf joints",
        ],
        "remedies": [
            "Remove infected tissue right away",
            "Disinfect tools after every cut",
            "Isolate the plant while it recovers",
        ],
        "prevention": [
            "Keep leaves dry after watering",
            "Sanitize tools between plants",
            "Improve airflow around the orchid",
        ],
        "imageText": "Orchid Soft Rot",
    },
    {
        "name": "Root Rot",
        "plantId": "peace-lily",
        "severity": "critical",
        "symptoms": [
            "Drooping leaves despite wet soil",
            "Soft or darkened roots",
            "Yellowing foliage and poor recovery",
        ],
        "causes": [
            "Frequent overwatering",
            "Heavy soil that holds excess moisture",
            "A pot without proper drainage",
        ],
        "remedies": [
            "Repot into fresh, airy mix",
            "Trim damaged roots before replanting",
            "Let the plant dry slightly between waterings",
        ],
        "prevention": [
            "Use a pot with drainage holes",
            "Water only when the top layer dries",
            "Never leave the pot sitting in water",
        ],
        "imageText": "Peace Lily Root Rot",
    },
    {
        "name": "Leaf Spot",
        "plantId": "peace-lily",
        "severity": "moderate",
        "symptoms": [
            "Brown or black patches on leaves",
            "Yellow halos around the damaged areas",
            "Aged leaves dropping early",
        ],
        "causes": [
            "High humidity and wet leaves",
            "Splashing water from overhead irrigation",
            "Poor cleanup of infected debris",
        ],
        "remedies": [
            "Remove spotted leaves",
            "Avoid wetting the foliage when watering",
            "Improve airflow around the plant",
        ],
        "prevention": [
            "Water at soil level",
            "Keep the growing area tidy",
            "Inspect the plant weekly",
        ],
        "imageText": "Peace Lily Leaf Spot",
    },
    {
        "name": "Root Rot",
        "plantId": "pothos",
        "severity": "critical",
        "symptoms": [
            "Yellowing leaves and limp stems",
            "Soft, dark roots",
            "Wilting that does not improve after watering",
        ],
        "causes": [
            "Too much water too often",
            "Soil that does not drain well",
            "A container that stays constantly soggy",
        ],
        "remedies": [
            "Repot into a lighter, well-draining mix",
            "Cut away rotted roots",
            "Reduce watering until growth stabilizes",
        ],
        "prevention": [
            "Let the top layer dry between waterings",
            "Use a pot with drainage holes",
            "Empty decorative cachepots after watering",
        ],
        "imageText": "Pothos Root Rot",
    },
    {
        "name": "Bacterial Leaf Spot",
        "plantId": "pothos",
        "severity": "moderate",
        "symptoms": [
            "Dark wet-looking spots on leaves",
            "Yellowing around damaged tissue",
            "Spots that expand quickly in wet weather",
        ],
        "causes": [
            "Water sitting on foliage",
            "Contaminated pruning tools",
            "Crowded plants with low airflow",
        ],
        "remedies": [
            "Remove affected leaves",
            "Disinfect tools and isolate the plant",
            "Keep foliage as dry as possible",
        ],
        "prevention": [
            "Water at the base",
            "Avoid overhead misting in cool weather",
            "Give the vine enough room to breathe",
        ],
        "imageText": "Pothos Leaf Spot",
    },
    {
        "name": "Root Rot",
        "plantId": "snake-plant",
        "severity": "critical",
        "symptoms": [
            "Soft leaves at the base",
            "Blackened roots or rhizomes",
            "Plant leaning or collapsing",
        ],
        "causes": [
            "Excess watering",
            "Dense, moisture-holding soil",
            "No drainage in the pot",
        ],
        "remedies": [
            "Remove damaged roots and repot",
            "Switch to a gritty cactus-style mix",
            "Hold water until the soil dries well",
        ],
        "prevention": [
            "Water sparingly",
            "Use fast-draining soil",
            "Never let the pot sit in runoff",
        ],
        "imageText": "Snake Plant Root Rot",
    },
    {
        "name": "Southern Blight",
        "plantId": "snake-plant",
        "severity": "high",
        "symptoms": [
            "Rapid basal rot near the soil line",
            "White fungal growth at the crown",
            "Plant decline that spreads quickly",
        ],
        "causes": [
            "Warm, wet soil conditions",
            "Infected potting media",
            "Splashing contaminated soil onto the crown",
        ],
        "remedies": [
            "Remove infected tissue and discard heavily affected plants",
            "Replace contaminated soil and clean the pot",
            "Reduce moisture around the base",
        ],
        "prevention": [
            "Use sterile potting mix",
            "Avoid overwatering",
            "Keep the soil line clean and dry",
        ],
        "imageText": "Snake Plant Southern Blight",
    },
]


PESTS: list[dict[str, Any]] = [
    {
        "name": "Aphids",
        "plantId": "rose",
        "severity": "moderate",
        "symptoms": [
            "Curled buds and distorted new leaves",
            "Sticky honeydew on stems and foliage",
            "Ant activity around the plant",
        ],
        "causes": [
            "Tender new growth",
            "Warm weather and sheltered shoots",
            "Nearby infested plants",
        ],
        "remedies": [
            "Rinse the plant with a strong water spray",
            "Use insecticidal soap or neem oil",
            "Prune heavily infested tips",
        ],
        "prevention": [
            "Inspect the undersides of leaves often",
            "Avoid excess nitrogen fertilizer",
            "Encourage beneficial insects",
        ],
        "imageText": "Rose Aphids",
    },
    {
        "name": "Mealybugs",
        "plantId": "hibiscus",
        "severity": "high",
        "symptoms": [
            "White cotton-like clusters in leaf joints",
            "Yellowing leaves and weak stems",
            "Sticky residue and sooty mold",
        ],
        "causes": [
            "Warm, sheltered plant joints",
            "Poor inspection of new plants",
            "Crowded branches with hidden nodes",
        ],
        "remedies": [
            "Wipe visible insects with alcohol on cotton",
            "Spray neem oil or insecticidal soap",
            "Isolate the plant until the outbreak slows",
        ],
        "prevention": [
            "Check nodes and leaf axils regularly",
            "Keep plants clean and spaced",
            "Quarantine newly purchased plants",
        ],
        "imageText": "Hibiscus Mealybugs",
    },
    {
        "name": "Whiteflies",
        "plantId": "hibiscus",
        "severity": "high",
        "symptoms": [
            "Tiny white insects fly up when the plant is moved",
            "Sticky surfaces and black sooty mold",
            "Leaves that yellow and weaken over time",
        ],
        "causes": [
            "Warm greenhouse or indoor conditions",
            "Poor leaf inspection",
            "Nearby infested plants",
        ],
        "remedies": [
            "Use yellow sticky traps",
            "Rinse foliage and apply neem spray",
            "Remove heavily infested leaves",
        ],
        "prevention": [
            "Check new growth weekly",
            "Keep air moving around the canopy",
            "Avoid overcrowding plants",
        ],
        "imageText": "Hibiscus Whiteflies",
    },
    {
        "name": "Aphids",
        "plantId": "jasmine",
        "severity": "moderate",
        "symptoms": [
            "Tender shoots curl or distort",
            "Sticky honeydew on new growth",
            "Bud development slows down",
        ],
        "causes": [
            "Soft new shoots",
            "Warm weather",
            "High nitrogen feeding",
        ],
        "remedies": [
            "Wash the plant with water",
            "Apply insecticidal soap",
            "Prune badly affected tips",
        ],
        "prevention": [
            "Inspect new growth frequently",
            "Avoid overfeeding with nitrogen",
            "Encourage beneficial insects nearby",
        ],
        "imageText": "Jasmine Aphids",
    },
    {
        "name": "Spider Mites",
        "plantId": "jasmine",
        "severity": "high",
        "symptoms": [
            "Fine stippling or bronzing on leaves",
            "Tiny webbing between stems and leaves",
            "Leaves look dull or dusty",
        ],
        "causes": [
            "Hot, dry conditions",
            "Dust buildup on the foliage",
            "Water stress from underwatering",
        ],
        "remedies": [
            "Wash the foliage thoroughly",
            "Apply neem oil or a miticide if needed",
            "Raise humidity and reduce dust",
        ],
        "prevention": [
            "Rinse or mist when appropriate",
            "Keep leaves clean",
            "Avoid letting the plant dry out too much",
        ],
        "imageText": "Jasmine Spider Mites",
    },
    {
        "name": "Thrips",
        "plantId": "marigold",
        "severity": "high",
        "symptoms": [
            "Silvery streaks on petals and leaves",
            "Distorted buds and flowers",
            "Tiny black specks of pest waste",
        ],
        "causes": [
            "Warm, dry weather",
            "Weedy or sheltered growing spaces",
            "Infested nursery stock",
        ],
        "remedies": [
            "Remove damaged blooms",
            "Use insecticidal soap or neem spray",
            "Set sticky traps near the plants",
        ],
        "prevention": [
            "Keep the area weed-free",
            "Inspect buds before they open",
            "Quarantine new plants",
        ],
        "imageText": "Marigold Thrips",
    },
    {
        "name": "Aphids",
        "plantId": "marigold",
        "severity": "moderate",
        "symptoms": [
            "Tender stems become curled or sticky",
            "New growth slows or stunts",
            "Ants may gather around the plant",
        ],
        "causes": [
            "Tender growth attracting insects",
            "Warm spring weather",
            "Nearby infested plants",
        ],
        "remedies": [
            "Rinse off the pests with water",
            "Use insecticidal soap",
            "Remove the worst affected tips",
        ],
        "prevention": [
            "Check the plant regularly",
            "Avoid excess fertilizer",
            "Encourage beneficial insects",
        ],
        "imageText": "Marigold Aphids",
    },
    {
        "name": "Mealybugs",
        "plantId": "orchid",
        "severity": "high",
        "symptoms": [
            "White cottony patches on leaves or stems",
            "Yellowing foliage and weak growth",
            "Sticky residue around the plant",
        ],
        "causes": [
            "Warm indoor conditions",
            "Poor inspection of new orchids",
            "Crowded crowns and hidden joints",
        ],
        "remedies": [
            "Wipe insects off with alcohol on cotton",
            "Apply neem oil or insecticidal soap",
            "Isolate the orchid while treating it",
        ],
        "prevention": [
            "Inspect nodes and leaf axils often",
            "Keep plants spaced and clean",
            "Quarantine new orchids",
        ],
        "imageText": "Orchid Mealybugs",
    },
    {
        "name": "Scale Insects",
        "plantId": "orchid",
        "severity": "moderate",
        "symptoms": [
            "Small brown bumps on stems or leaves",
            "Sticky residue and weak growth",
            "Leaves turn yellow over time",
        ],
        "causes": [
            "Infested nursery stock",
            "Low airflow around the plant",
            "Stress from poor watering or light",
        ],
        "remedies": [
            "Scrape off visible insects carefully",
            "Repeat neem or soap treatment",
            "Check the plant again after a week",
        ],
        "prevention": [
            "Inspect stems and undersides regularly",
            "Keep orchids healthy and unstressed",
            "Quarantine new plants before mixing them in",
        ],
        "imageText": "Orchid Scale Insects",
    },
    {
        "name": "Mealybugs",
        "plantId": "peace-lily",
        "severity": "high",
        "symptoms": [
            "Cottony clusters in leaf joints",
            "Sticky residue on leaves and pots",
            "Leaves weaken and yellow",
        ],
        "causes": [
            "Warm indoor hiding spots",
            "Poor inspection of new plants",
            "Crowded foliage and hidden nodes",
        ],
        "remedies": [
            "Wipe off visible insects with alcohol",
            "Spray neem oil or insecticidal soap",
            "Isolate the plant until it clears",
        ],
        "prevention": [
            "Check nodes and leaf axils regularly",
            "Keep the plant clean and spaced",
            "Quarantine new houseplants",
        ],
        "imageText": "Peace Lily Mealybugs",
    },
    {
        "name": "Spider Mites",
        "plantId": "peace-lily",
        "severity": "moderate",
        "symptoms": [
            "Tiny yellow speckles across the leaves",
            "Fine webbing in heavy infestations",
            "Dry, dull-looking foliage",
        ],
        "causes": [
            "Hot, dry indoor air",
            "Dust buildup on leaves",
            "Plants under watering stress",
        ],
        "remedies": [
            "Wash the leaves thoroughly",
            "Use neem oil if the infestation persists",
            "Raise humidity and reduce dust",
        ],
        "prevention": [
            "Rinse leaves occasionally when appropriate",
            "Keep the plant away from very dry vents",
            "Avoid underwatering",
        ],
        "imageText": "Peace Lily Spider Mites",
    },
    {
        "name": "Mealybugs",
        "plantId": "pothos",
        "severity": "high",
        "symptoms": [
            "White cottony tufts in leaf joints",
            "Sticky honeydew on vines",
            "Leaves turn yellow and lose vigor",
        ],
        "causes": [
            "Warm sheltered nodes",
            "Poor inspection of plant cuttings",
            "Crowded indoor growing areas",
        ],
        "remedies": [
            "Wipe pests off with alcohol on cotton",
            "Use insecticidal soap or neem spray",
            "Prune the most infested tips",
        ],
        "prevention": [
            "Inspect nodes often",
            "Keep vines spaced and clean",
            "Quarantine any new cuttings",
        ],
        "imageText": "Pothos Mealybugs",
    },
    {
        "name": "Scale Insects",
        "plantId": "pothos",
        "severity": "moderate",
        "symptoms": [
            "Small brown bumps on stems and leaves",
            "Sticky residue and sooty mold",
            "Slow, weak vine growth",
        ],
        "causes": [
            "Stress from poor lighting or watering",
            "Low airflow around indoor plants",
            "Infested nursery stock",
        ],
        "remedies": [
            "Scrape off visible scale",
            "Repeat neem or soap treatment as needed",
            "Isolate the plant during treatment",
        ],
        "prevention": [
            "Check stems and leaf undersides",
            "Keep the plant healthy and unstressed",
            "Quarantine new plants before placement",
        ],
        "imageText": "Pothos Scale Insects",
    },
    {
        "name": "Mealybugs",
        "plantId": "snake-plant",
        "severity": "moderate",
        "symptoms": [
            "Cottony white clusters at the base or leaves",
            "Sticky residue and weak growth",
            "Yellowing or distorted foliage",
        ],
        "causes": [
            "Dry indoor hiding spots",
            "Poor inspection of new plants",
            "Crowded leaf joints and dust buildup",
        ],
        "remedies": [
            "Wipe off visible insects with alcohol",
            "Use neem spray or insecticidal soap",
            "Repeat treatment until the pests are gone",
        ],
        "prevention": [
            "Inspect the base and leaf joints often",
            "Keep the plant clean",
            "Quarantine new indoor plants",
        ],
        "imageText": "Snake Plant Mealybugs",
    },
    {
        "name": "Fungus Gnats",
        "plantId": "snake-plant",
        "severity": "low",
        "symptoms": [
            "Tiny flying adults around the soil",
            "Larvae in damp potting mix",
            "Slow decline in young plants",
        ],
        "causes": [
            "Soil that stays too wet",
            "Organic-rich potting mix",
            "Poor drainage in the pot",
        ],
        "remedies": [
            "Let the soil dry between waterings",
            "Use sticky traps for adults",
            "Repot if the mix stays soggy",
        ],
        "prevention": [
            "Water sparingly",
            "Use a gritty, fast-draining mix",
            "Empty saucers after watering",
        ],
        "imageText": "Snake Plant Fungus Gnats",
    },
]


def placeholder_url(text: str) -> str:
    return f"https://placehold.co/1200x800/png?text={quote_plus(text)}"


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug or "item"


def ensure_firebase_app() -> firebase_admin.App:
    try:
        return firebase_admin.get_app()
    except ValueError:
        pass

    service_account_path = (
        os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH", "").strip()
        or os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "").strip()
    )
    project_id = os.getenv("FIREBASE_PROJECT_ID", "").strip()

    if service_account_path:
        cred = credentials.Certificate(service_account_path)
        options: dict[str, Any] = {}
        if project_id:
            options["projectId"] = project_id
        return firebase_admin.initialize_app(cred, options or None)

    if project_id:
        return firebase_admin.initialize_app(options={"projectId": project_id})

    return firebase_admin.initialize_app()


def write_documents(
    db: firestore.Client,
    collection_name: str,
    documents: list[tuple[str, dict[str, Any]]],
) -> None:
    batch = db.batch()
    count = 0

    for document_id, payload in documents:
        batch.set(db.collection(collection_name).document(document_id), payload)
        count += 1
        if count % 400 == 0:
            batch.commit()
            batch = db.batch()

    if count % 400 != 0:
        batch.commit()


def plant_documents() -> list[tuple[str, dict[str, Any]]]:
    return [
        (
            plant["id"],
            {
                "commonName": plant["commonName"],
                "scientificName": plant["scientificName"],
                "category": plant["category"],
                "aliases": plant["aliases"],
                "description": plant["description"],
            },
        )
        for plant in PLANTS
    ]


def condition_documents(items: list[dict[str, Any]]) -> list[tuple[str, dict[str, Any]]]:
    documents: list[tuple[str, dict[str, Any]]] = []

    for item in items:
        plant_id = item["plantId"]
        doc_id = slugify(f"{plant_id}-{item['name']}")
        payload = {
            "name": item["name"],
            "plantId": plant_id,
            "symptoms": item["symptoms"],
            "causes": item["causes"],
            "remedies": item["remedies"],
            "prevention": item["prevention"],
            "severity": item["severity"],
            "imageUrl": placeholder_url(item["imageText"]),
        }
        documents.append((doc_id, payload))

    return documents


def seed_firestore() -> dict[str, int]:
    ensure_firebase_app()
    db = firestore.client()

    plants = plant_documents()
    diseases = condition_documents(DISEASES)
    pests = condition_documents(PESTS)

    write_documents(db, "plants", plants)
    write_documents(db, "diseases", diseases)
    write_documents(db, "pests", pests)

    return {
        "plants": len(plants),
        "diseases": len(diseases),
        "pests": len(pests),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Seed FloraMind AI Firestore with starter disease and pest library data.",
    )
    return parser.parse_args()


def main() -> int:
    parse_args()
    counts = seed_firestore()
    print(
        "Seeded Firestore with "
        f"{counts['plants']} plants, {counts['diseases']} diseases, and {counts['pests']} pests.",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
