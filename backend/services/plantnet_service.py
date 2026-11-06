from __future__ import annotations

import io
from dataclasses import dataclass
from typing import Any

import requests
from PIL import Image


ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "webp"}
ALLOWED_ORGANS = {"auto", "leaf", "flower", "fruit", "bark"}


class PlantNetInputError(Exception):
    """Raised when the uploaded image or request data is invalid."""


class PlantNetConfigurationError(Exception):
    """Raised when the backend is missing required PlantNet configuration."""


class PlantNetRateLimitError(Exception):
    """Raised when PlantNet throttles the request."""


class PlantNetIdentificationError(Exception):
    """Raised when PlantNet returns an API or upstream error."""

    def __init__(self, message: str, status_code: int = 502) -> None:
        super().__init__(message)
        self.status_code = status_code


@dataclass
class _NormalizedImage:
    file_name: str
    mime_type: str
    file_bytes: bytes


def _extension_from_filename(filename: str) -> str:
    if "." not in filename:
        return ""
    return filename.rsplit(".", 1)[-1].lower().strip()


def _normalize_organ(organ: str | None) -> str:
    normalized = (organ or "flower").strip().lower()
    if normalized not in ALLOWED_ORGANS:
        raise PlantNetInputError(
            "Invalid organ value. Use auto, leaf, flower, fruit, or bark.",
        )
    return normalized


def _normalize_image(image_file) -> _NormalizedImage:
    if image_file is None or not image_file.filename:
        raise PlantNetInputError("No image was uploaded.")

    filename = image_file.filename
    extension = _extension_from_filename(filename)
    if extension not in ALLOWED_EXTENSIONS:
        raise PlantNetInputError(
            "Unsupported image type. Use jpg, jpeg, png, or webp.",
        )

    raw_bytes = image_file.read()
    if not raw_bytes:
        raise PlantNetInputError("The uploaded image is empty.")

    if extension == "webp":
        try:
            with Image.open(io.BytesIO(raw_bytes)) as source_image:
                converted = io.BytesIO()
                if source_image.mode != "RGB":
                    source_image = source_image.convert("RGB")
                source_image.save(converted, format="PNG")
                return _NormalizedImage(
                    file_name="plant-image.png",
                    mime_type="image/png",
                    file_bytes=converted.getvalue(),
                )
        except Exception as exc:
            raise PlantNetInputError(
                "The uploaded WEBP image could not be processed.",
            ) from exc

    mime_type = "image/jpeg" if extension in {"jpg", "jpeg"} else "image/png"
    if extension == "jpeg" or extension == "jpg":
        file_name = "plant-image.jpg"
    elif extension == "png":
        file_name = "plant-image.png"
    else:
        file_name = "plant-image.jpg"

    return _NormalizedImage(
        file_name=file_name,
        mime_type=mime_type,
        file_bytes=raw_bytes,
    )


def _extract_common_name(species: dict[str, Any]) -> str:
    common_names = species.get("commonNames") or []
    if common_names:
        return str(common_names[0])
    return (
        species.get("scientificNameWithoutAuthor")
        or species.get("scientificName")
        or "Unknown"
    )


def _extract_scientific_name(species: dict[str, Any]) -> str:
    return (
        species.get("scientificNameWithoutAuthor")
        or species.get("scientificName")
        or "Unknown"
    )


def _build_candidate(candidate: dict[str, Any]) -> dict[str, Any]:
    species = candidate.get("species") or {}
    return {
        "common_name": _extract_common_name(species),
        "scientific_name": _extract_scientific_name(species),
        "confidence": round(float(candidate.get("score", 0.0)), 4),
    }


def identify_plant(
    *,
    image_file,
    api_key: str,
    api_base_url: str,
    project: str,
    lang: str,
    result_count: int,
    confidence_threshold: float,
    organ: str | None = None,
) -> dict[str, Any]:
    if not api_key:
        raise PlantNetConfigurationError(
            "PlantNet API key is missing from the backend environment.",
        )

    normalized_organ = _normalize_organ(organ)
    normalized_image = _normalize_image(image_file)

    endpoint = f"{api_base_url}/v2/identify/{project}"
    params = {
        "api-key": api_key,
        "lang": lang,
        "nb-results": result_count,
        "detailed": "true",
        "no-reject": "true",
    }
    data = {
        "organs": normalized_organ,
    }
    files = {
        "images": (
            normalized_image.file_name,
            normalized_image.file_bytes,
            normalized_image.mime_type,
        ),
    }

    try:
        response = requests.post(
            endpoint,
            params=params,
            data=data,
            files=files,
            timeout=60,
        )
    except requests.Timeout as exc:
        raise PlantNetIdentificationError(
            "The PlantNet request timed out.",
            504,
        ) from exc
    except requests.RequestException as exc:
        raise PlantNetIdentificationError(
            "PlantNet is unavailable right now.",
            502,
        ) from exc

    if response.status_code in {401, 403}:
        raise PlantNetIdentificationError(
            "Invalid PlantNet API key.",
            401,
        )
    if response.status_code == 429:
        raise PlantNetRateLimitError(
            "PlantNet rate limit reached. Please try again later.",
        )
    if response.status_code >= 500:
        raise PlantNetIdentificationError(
            "PlantNet is temporarily unavailable.",
            502,
        )
    if response.status_code >= 400:
        raise PlantNetIdentificationError(
            "PlantNet rejected the uploaded image.",
            response.status_code,
        )

    try:
        payload = response.json()
    except ValueError as exc:
        raise PlantNetIdentificationError(
            "PlantNet returned an unexpected response.",
            502,
        ) from exc
    results = payload.get("results") or []
    if not results:
        return {
            "success": False,
            "message": "Plant could not be identified confidently.",
            "alternatives": [],
        }

    top_candidate = results[0]
    top_score = float(top_candidate.get("score", 0.0))
    if top_score < confidence_threshold:
        return {
            "success": False,
            "message": "Plant could not be identified confidently.",
            "alternatives": [],
        }

    top_species = top_candidate.get("species") or {}
    top_family = top_species.get("family") or {}
    top_genus = top_species.get("genus") or {}
    alternatives = [
        _build_candidate(candidate)
        for candidate in results[1:result_count]
    ]

    return {
        "success": True,
        "plant": {
            "common_name": _extract_common_name(top_species),
            "scientific_name": _extract_scientific_name(top_species),
            "family": (
                top_family.get("scientificNameWithoutAuthor")
                or top_family.get("scientificName")
                or "Unknown"
            ),
            "genus": (
                top_genus.get("scientificNameWithoutAuthor")
                or top_genus.get("scientificName")
                or "Unknown"
            ),
            "confidence": round(top_score, 4),
        },
        "alternatives": alternatives,
    }
