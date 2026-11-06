from flask import Flask, jsonify
from flask_cors import CORS

from config import Config
from routes.plant_routes import plant_bp


def create_app() -> Flask:
    app = Flask(__name__)
    app.config.from_object(Config)

    CORS(app)

    app.register_blueprint(plant_bp, url_prefix="/api/plant")

    @app.get("/api/health")
    def health_check():
        return jsonify({
            "success": True,
            "message": "FloraMind AI backend is running",
        })

    return app


app = create_app()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=app.config["PORT"], debug=app.config["DEBUG"])
