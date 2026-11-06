import os
from pathlib import Path

from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")


class Config:
    PORT = int(os.getenv("PORT", "5000"))
    DEBUG = os.getenv("FLASK_DEBUG", "true").lower() == "true"
    PLANTNET_API_KEY = os.getenv("PLANTNET_API_KEY", "").strip()
    PLANTNET_API_BASE_URL = os.getenv(
        "PLANTNET_API_BASE_URL",
        "https://my-api.plantnet.org",
    ).rstrip("/")
    PLANTNET_PROJECT = os.getenv("PLANTNET_PROJECT", "all").strip() or "all"
    PLANTNET_LANG = os.getenv("PLANTNET_LANG", "en").strip() or "en"
    PLANTNET_RESULTS = int(os.getenv("PLANTNET_RESULTS", "5"))
    PLANTNET_CONFIDENCE_THRESHOLD = float(
        os.getenv("PLANTNET_CONFIDENCE_THRESHOLD", "0.30"),
    )
    MAX_CONTENT_LENGTH = int(
        os.getenv("MAX_CONTENT_LENGTH", str(20 * 1024 * 1024)),
    )

