"""
Convert the saved FloraMind AI plant detection model to TensorFlow Lite.

This script:
- loads the existing Keras model
- converts it to a .tflite file
- saves best_plant_detection_model.tflite
- leaves class_names.json unchanged
- verifies that the generated TFLite model can be loaded

It is intentionally small and beginner-friendly so it can be run in Colab
after training is complete.
"""

from __future__ import annotations

from pathlib import Path

import tensorflow as tf


BASE_DIR = Path("/content/drive/MyDrive/FloraMindAI")
OUTPUT_DIR = BASE_DIR / "plant_detection_outputs"
MODEL_PATH = OUTPUT_DIR / "best_plant_detection_model.keras"
TFLITE_PATH = OUTPUT_DIR / "best_plant_detection_model.tflite"


def mount_drive_if_needed() -> None:
    """Mount Google Drive when running in Colab."""
    try:
        from google.colab import drive

        drive.mount("/content/drive")
    except ImportError:
        print("google.colab is not available. Continuing without Drive mount.")


def main() -> None:
    mount_drive_if_needed()

    if not MODEL_PATH.exists():
        raise FileNotFoundError(f"Keras model not found: {MODEL_PATH}")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Loading Keras model from: {MODEL_PATH}")
    model = tf.keras.models.load_model(MODEL_PATH, compile=False)

    print("Converting to TensorFlow Lite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()

    TFLITE_PATH.write_bytes(tflite_model)
    print(f"Saved TFLite model to: {TFLITE_PATH}")

    print("Verifying the TFLite model can be loaded...")
    interpreter = tf.lite.Interpreter(model_path=str(TFLITE_PATH))
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    print("TFLite model loaded successfully.")
    print(f"Input tensors: {len(input_details)}")
    print(f"Output tensors: {len(output_details)}")

    # This script does not read or rewrite class_names.json.


if __name__ == "__main__":
    main()
