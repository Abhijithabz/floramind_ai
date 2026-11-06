"""
FloraMind AI Plant Detection training pipeline for Google Colab.

What this script does:
- Mounts Google Drive
- Loads a folder-based plant dataset
- Detects classes automatically
- Shows image counts per class
- Splits the data into train/validation/test
- Trains MobileNetV2 and EfficientNetB0
- Evaluates accuracy, precision, recall, and F1-score
- Saves reports, plots, the best model, and class names
- Exports a clean SavedModel artifact for later TFLite conversion
"""

from __future__ import annotations

import json
import random
import shutil
from collections import Counter
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.metrics import (
    ConfusionMatrixDisplay,
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
)
from sklearn.model_selection import train_test_split


# ============================================================
# 1) Basic setup
# ============================================================

SEED = 42
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 12
LEARNING_RATE = 1e-4
OUTPUT_DIR = Path("/content/drive/MyDrive/FloraMindAI/plant_detection_outputs")
DATASET_DIR = Path("/content/drive/MyDrive/FloraMind_AI/Dataset/house_plant_species")
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp", ".gif"}

tf.keras.utils.set_random_seed(SEED)
np.random.seed(SEED)
random.seed(SEED)

try:
    gpus = tf.config.list_physical_devices("GPU")
    for gpu in gpus:
        tf.config.experimental.set_memory_growth(gpu, True)
except Exception:
    pass

try:
    from google.colab import drive

    drive.mount("/content/drive")
except ImportError:
    print("google.colab is not available. Run this script inside Colab.")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def ensure_dataset_dir(path: Path) -> None:
    """Make sure the dataset path exists."""
    if not path.exists():
        raise FileNotFoundError(
            f"Dataset folder not found: {path}\n"
            "Update DATASET_DIR so it points to your Google Drive plant dataset."
        )


# ============================================================
# 2) Scan the dataset and detect classes
# ============================================================


def discover_dataset(root_dir: Path) -> Tuple[List[str], List[str], List[int]]:
    """
    Read image file paths from class subfolders.

    Expected structure:
      root_dir/
        class_a/
          img1.jpg
          img2.jpg
        class_b/
          img3.jpg
    """
    class_names = sorted([item.name for item in root_dir.iterdir() if item.is_dir()])
    if not class_names:
        raise ValueError(
            f"No class folders found inside {root_dir}.\n"
            "Each plant class should have its own folder."
        )

    class_to_index = {name: idx for idx, name in enumerate(class_names)}
    filepaths: List[str] = []
    labels: List[int] = []

    for class_name in class_names:
        class_dir = root_dir / class_name
        for path in sorted(class_dir.rglob("*")):
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS:
                filepaths.append(str(path))
                labels.append(class_to_index[class_name])

    if not filepaths:
        raise ValueError(
            f"No image files were found in {root_dir}.\n"
            "Check that the dataset folder contains supported image files."
        )

    return class_names, filepaths, labels


def show_class_counts(class_names: List[str], labels: List[int]) -> pd.DataFrame:
    """Print and plot how many images each class has."""
    counts = Counter(labels)
    table = pd.DataFrame(
        {
            "class_name": class_names,
            "image_count": [counts.get(i, 0) for i in range(len(class_names))],
        }
    )

    print("\nImage count per class:")
    print(table.to_string(index=False))

    plt.figure(figsize=(max(10, len(class_names) * 0.6), 5))
    plt.bar(table["class_name"], table["image_count"], color="#4C9F70")
    plt.xticks(rotation=45, ha="right")
    plt.title("Image Count per Class")
    plt.xlabel("Class")
    plt.ylabel("Images")
    plt.tight_layout()
    plt.show()

    return table


# ============================================================
# 3) Split 80 / 10 / 10
# ============================================================


def split_paths(
    filepaths: List[str], labels: List[int]
) -> Tuple[List[str], List[str], List[str], List[int], List[int], List[int]]:
    """
    Split the dataset into train, validation, and test sets.

    We try a stratified split first so class balance stays similar.
    If a very small class causes a split error, we fall back to a
    simple per-class split.
    """
    try:
        train_paths, temp_paths, train_labels, temp_labels = train_test_split(
            filepaths,
            labels,
            test_size=0.2,
            random_state=SEED,
            stratify=labels,
        )

        val_paths, test_paths, val_labels, test_labels = train_test_split(
            temp_paths,
            temp_labels,
            test_size=0.5,
            random_state=SEED,
            stratify=temp_labels,
        )
        return train_paths, val_paths, test_paths, train_labels, val_labels, test_labels

    except ValueError:
        print(
            "Stratified split failed because at least one class is very small.\n"
            "Using a fallback per-class split instead."
        )

        rng = np.random.default_rng(SEED)
        grouped: Dict[int, List[str]] = {}
        for path, label in zip(filepaths, labels):
            grouped.setdefault(label, []).append(path)

        train_paths: List[str] = []
        val_paths: List[str] = []
        test_paths: List[str] = []
        train_labels: List[int] = []
        val_labels: List[int] = []
        test_labels: List[int] = []

        for label, paths in grouped.items():
            paths = paths.copy()
            rng.shuffle(paths)
            n = len(paths)

            n_train = max(1, int(round(n * 0.8)))
            n_val = max(1, int(round(n * 0.1))) if n >= 3 else 0

            if n_train + n_val >= n:
                n_train = max(1, n - 2) if n >= 3 else max(1, n - 1)
                n_val = 1 if n - n_train >= 2 else max(0, n - n_train - 1)

            n_test = n - n_train - n_val
            if n_test <= 0 and n >= 3:
                n_test = 1
                if n_train > n_val and n_train > 1:
                    n_train -= 1
                elif n_val > 0:
                    n_val -= 1

            train_chunk = paths[:n_train]
            val_chunk = paths[n_train : n_train + n_val]
            test_chunk = paths[n_train + n_val :]

            train_paths.extend(train_chunk)
            val_paths.extend(val_chunk)
            test_paths.extend(test_chunk)
            train_labels.extend([label] * len(train_chunk))
            val_labels.extend([label] * len(val_chunk))
            test_labels.extend([label] * len(test_chunk))

        return train_paths, val_paths, test_paths, train_labels, val_labels, test_labels


# ============================================================
# 4) Build tf.data datasets
# ============================================================


AUTO = tf.data.AUTOTUNE

data_augmentation = tf.keras.Sequential(
    [
        tf.keras.layers.RandomFlip("horizontal"),
        tf.keras.layers.RandomRotation(0.1),
        tf.keras.layers.RandomZoom(0.1),
        tf.keras.layers.RandomContrast(0.1),
    ],
    name="data_augmentation",
)


def load_and_resize_image(path: tf.Tensor, label: tf.Tensor) -> Tuple[tf.Tensor, tf.Tensor]:
    """Load an image file and resize it to 224x224."""
    image_bytes = tf.io.read_file(path)
    image = tf.image.decode_image(image_bytes, channels=3, expand_animations=False)
    image = tf.cast(image, tf.float32)  # Keep pixels in [0, 255].
    image = tf.image.resize(image, IMG_SIZE)
    image.set_shape([IMG_SIZE[0], IMG_SIZE[1], 3])
    return image, label


def make_dataset(
    paths: List[str],
    labels: List[int],
    training: bool = False,
) -> tf.data.Dataset:
    """Create a batched and prefetched dataset."""
    ds = tf.data.Dataset.from_tensor_slices((paths, labels))
    if training:
        ds = ds.shuffle(buffer_size=len(paths), seed=SEED, reshuffle_each_iteration=True)
    ds = ds.map(load_and_resize_image, num_parallel_calls=AUTO)
    if training:
        ds = ds.map(
            lambda image, label: (data_augmentation(image, training=True), label),
            num_parallel_calls=AUTO,
        )
    ds = ds.batch(BATCH_SIZE).prefetch(AUTO)
    return ds


# ============================================================
# 5) Build two transfer-learning models
# ============================================================


def build_model(model_name: str, num_classes: int) -> tf.keras.Model:
    """Create a transfer-learning classifier."""
    inputs = tf.keras.Input(shape=(*IMG_SIZE, 3), name="image")

    if model_name == "MobileNetV2":
        x = tf.keras.layers.Rescaling(1.0 / 127.5, offset=-1.0, name="mobilenet_rescale")(inputs)
        base_model = tf.keras.applications.MobileNetV2(
            include_top=False,
            weights="imagenet",
            input_shape=(*IMG_SIZE, 3),
        )
    elif model_name == "EfficientNetB0":
        x = inputs
        base_model = tf.keras.applications.EfficientNetB0(
            include_top=False,
            weights="imagenet",
            input_shape=(*IMG_SIZE, 3),
        )
    else:
        raise ValueError(f"Unsupported model name: {model_name}")

    base_model.trainable = False

    x = base_model(x, training=False)
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    x = tf.keras.layers.Dropout(0.2)(x)
    outputs = tf.keras.layers.Dense(num_classes, activation="softmax")(x)

    model = tf.keras.Model(inputs, outputs, name=model_name)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=LEARNING_RATE),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


# ============================================================
# 6) Train, evaluate, and save outputs
# ============================================================


def plot_history(history: tf.keras.callbacks.History, title: str, output_path: Path) -> None:
    """Save training curves for loss and accuracy."""
    history_data = history.history
    epochs = range(1, len(history_data["loss"]) + 1)

    plt.figure(figsize=(12, 5))

    plt.subplot(1, 2, 1)
    plt.plot(epochs, history_data["loss"], label="Train loss")
    plt.plot(epochs, history_data["val_loss"], label="Val loss")
    plt.title(f"{title} Loss")
    plt.xlabel("Epoch")
    plt.ylabel("Loss")
    plt.legend()

    plt.subplot(1, 2, 2)
    plt.plot(epochs, history_data["accuracy"], label="Train accuracy")
    plt.plot(epochs, history_data["val_accuracy"], label="Val accuracy")
    plt.title(f"{title} Accuracy")
    plt.xlabel("Epoch")
    plt.ylabel("Accuracy")
    plt.legend()

    plt.tight_layout()
    plt.savefig(output_path, dpi=150, bbox_inches="tight")
    plt.show()
    plt.close()


def predict_labels(model: tf.keras.Model, dataset: tf.data.Dataset) -> Tuple[np.ndarray, np.ndarray]:
    """Return true labels and predicted labels for a dataset."""
    y_true = np.concatenate([labels.numpy() for _, labels in dataset], axis=0)
    y_prob = model.predict(dataset, verbose=0)
    y_pred = np.argmax(y_prob, axis=1)
    return y_true, y_pred


def evaluate_and_save(
    model: tf.keras.Model,
    dataset: tf.data.Dataset,
    class_names: List[str],
    name: str,
    output_dir: Path,
) -> Dict[str, float]:
    """Evaluate a model and save its report and confusion matrix."""
    safe_name = name.lower().replace(" ", "_")
    y_true, y_pred = predict_labels(model, dataset)
    labels = list(range(len(class_names)))

    metrics = {
        "accuracy": accuracy_score(y_true, y_pred),
        "precision": precision_score(y_true, y_pred, average="macro", zero_division=0),
        "recall": recall_score(y_true, y_pred, average="macro", zero_division=0),
        "f1": f1_score(y_true, y_pred, average="macro", zero_division=0),
    }

    report = classification_report(
        y_true,
        y_pred,
        labels=labels,
        target_names=class_names,
        digits=4,
        zero_division=0,
    )

    print(f"\n{name} classification report:")
    print(report)

    report_path = output_dir / f"{safe_name}_classification_report.txt"
    report_path.write_text(report, encoding="utf-8")

    cm = confusion_matrix(y_true, y_pred, labels=labels)
    cm_df = pd.DataFrame(cm, index=class_names, columns=class_names)
    cm_df.to_csv(output_dir / f"{safe_name}_confusion_matrix.csv")

    fig, ax = plt.subplots(figsize=(max(10, len(class_names) * 0.6), max(8, len(class_names) * 0.6)))
    display = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=class_names)
    display.plot(ax=ax, cmap="Blues", colorbar=True, xticks_rotation=45, values_format="d")
    ax.set_title(f"{name} Confusion Matrix")
    plt.tight_layout()
    plt.savefig(output_dir / f"{safe_name}_confusion_matrix.png", dpi=150, bbox_inches="tight")
    plt.show()
    plt.close(fig)

    return metrics


def train_single_model(
    model_name: str,
    train_ds: tf.data.Dataset,
    val_ds: tf.data.Dataset,
    test_ds: tf.data.Dataset,
    class_names: List[str],
    output_dir: Path,
) -> Dict[str, object]:
    """Train one model, then evaluate it on validation and test data."""
    tf.keras.backend.clear_session()

    model = build_model(model_name, num_classes=len(class_names))
    model.summary()

    checkpoint_path = output_dir / f"{model_name.lower()}_best.keras"

    callbacks = [
        tf.keras.callbacks.ModelCheckpoint(
            filepath=str(checkpoint_path),
            monitor="val_accuracy",
            mode="max",
            save_best_only=True,
            verbose=1,
        ),
        tf.keras.callbacks.EarlyStopping(
            monitor="val_loss",
            patience=4,
            restore_best_weights=True,
            verbose=1,
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.5,
            patience=2,
            verbose=1,
        ),
    ]

    history = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1,
    )

    # Reload the best checkpoint from training.
    best_model = tf.keras.models.load_model(checkpoint_path)

    plot_history(
        history,
        title=model_name,
        output_path=output_dir / f"{model_name.lower()}_training_curves.png",
    )

    val_metrics = evaluate_and_save(
        best_model,
        val_ds,
        class_names,
        f"{model_name} Validation",
        output_dir,
    )

    test_metrics = evaluate_and_save(
        best_model,
        test_ds,
        class_names,
        f"{model_name} Test",
        output_dir,
    )

    return {
        "model_name": model_name,
        "history": history,
        "model": best_model,
        "val_metrics": val_metrics,
        "test_metrics": test_metrics,
        "checkpoint_path": checkpoint_path,
    }


# ============================================================
# 7) Run the full pipeline
# ============================================================


def main() -> None:
    ensure_dataset_dir(DATASET_DIR)

    class_names, filepaths, labels = discover_dataset(DATASET_DIR)
    show_class_counts(class_names, labels)

    train_paths, val_paths, test_paths, train_labels, val_labels, test_labels = split_paths(
        filepaths, labels
    )

    print("\nSplit sizes:")
    print(f"Train: {len(train_paths)}")
    print(f"Validation: {len(val_paths)}")
    print(f"Test: {len(test_paths)}")

    train_ds = make_dataset(train_paths, train_labels, training=True)
    val_ds = make_dataset(val_paths, val_labels, training=False)
    test_ds = make_dataset(test_paths, test_labels, training=False)

    model_results = {}
    for model_name in ["MobileNetV2", "EfficientNetB0"]:
        print("\n" + "=" * 70)
        print(f"Training {model_name}")
        print("=" * 70)
        model_results[model_name] = train_single_model(
            model_name=model_name,
            train_ds=train_ds,
            val_ds=val_ds,
            test_ds=test_ds,
            class_names=class_names,
            output_dir=OUTPUT_DIR,
        )

    # Compare models using validation F1-score.
    summary_rows = []
    for name, result in model_results.items():
        row = {
            "model": name,
            "val_accuracy": result["val_metrics"]["accuracy"],
            "val_precision": result["val_metrics"]["precision"],
            "val_recall": result["val_metrics"]["recall"],
            "val_f1": result["val_metrics"]["f1"],
            "test_accuracy": result["test_metrics"]["accuracy"],
            "test_precision": result["test_metrics"]["precision"],
            "test_recall": result["test_metrics"]["recall"],
            "test_f1": result["test_metrics"]["f1"],
        }
        summary_rows.append(row)

    summary_df = pd.DataFrame(summary_rows).sort_values("val_f1", ascending=False)
    print("\nModel comparison:")
    print(summary_df.to_string(index=False))
    summary_df.to_csv(OUTPUT_DIR / "model_comparison.csv", index=False)

    best_model_name = str(summary_df.iloc[0]["model"])
    best_model = model_results[best_model_name]["model"]

    # Save the final best model in Keras format.
    best_model_path = OUTPUT_DIR / "best_plant_detection_model.keras"
    best_model.save(best_model_path)

    # Save class names for Flutter and later TFLite labels.
    class_names_path = OUTPUT_DIR / "class_names.json"
    class_names_path.write_text(json.dumps(class_names, indent=2), encoding="utf-8")

    # Export a clean SavedModel artifact for later TFLite conversion.
    exported_model_dir = OUTPUT_DIR / "best_plant_detection_saved_model"
    if exported_model_dir.exists():
        shutil.rmtree(exported_model_dir)
    best_model.export(exported_model_dir)

    print("\nBest model saved:")
    print(f"Model name: {best_model_name}")
    print(f"Keras file: {best_model_path}")
    print(f"SavedModel directory: {exported_model_dir}")
    print(f"Class names file: {class_names_path}")

    print("\nLater TFLite conversion example:")
    print("# converter = tf.lite.TFLiteConverter.from_saved_model(str(exported_model_dir))")
    print("# tflite_model = converter.convert()")
    print("# (OUTPUT_DIR / 'best_plant_detection_model.tflite').write_bytes(tflite_model)")


if __name__ == "__main__":
    main()
