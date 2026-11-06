from flask import Blueprint, current_app, jsonify, request

from services.plantnet_service import (
    PlantNetConfigurationError,
    PlantNetIdentificationError,
    PlantNetInputError,
    PlantNetRateLimitError,
    identify_plant,
)


plant_bp = Blueprint("plant", __name__)


@plant_bp.post("/identify")
def identify_route():
    image = request.files.get("image")
    if image is None or not image.filename:
        return jsonify({
            "success": False,
            "message": "No image was uploaded.",
            "alternatives": [],
        }), 400

    organ = request.form.get("organ", "flower")

    try:
        result = identify_plant(
            image_file=image,
            api_key=current_app.config["PLANTNET_API_KEY"],
            api_base_url=current_app.config["PLANTNET_API_BASE_URL"],
            project=current_app.config["PLANTNET_PROJECT"],
            lang=current_app.config["PLANTNET_LANG"],
            result_count=current_app.config["PLANTNET_RESULTS"],
            confidence_threshold=current_app.config["PLANTNET_CONFIDENCE_THRESHOLD"],
            organ=organ,
        )
        return jsonify(result), 200
    except PlantNetInputError as exc:
        return jsonify({
            "success": False,
            "message": str(exc),
            "alternatives": [],
        }), 400
    except PlantNetConfigurationError as exc:
        return jsonify({
            "success": False,
            "message": str(exc),
            "alternatives": [],
        }), 500
    except PlantNetRateLimitError as exc:
        return jsonify({
            "success": False,
            "message": str(exc),
            "alternatives": [],
        }), 429
    except PlantNetIdentificationError as exc:
        return jsonify({
            "success": False,
            "message": str(exc),
            "alternatives": [],
        }), exc.status_code

