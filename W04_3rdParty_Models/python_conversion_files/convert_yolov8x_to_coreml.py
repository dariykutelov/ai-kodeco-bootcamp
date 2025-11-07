import os
from ultralytics import YOLO
import coremltools as ct

print("🔹 Loading YOLOv8x classification model...")
model = YOLO("yolov8x-cls.pt")

# 1. Export YOLOv8 model to Core ML
print("🔹 Exporting to Core ML format...")
model.export(format="coreml", imgsz=(224, 224), name="yolov8x-cls")
mlpackage_path = "yolov8x-cls.mlpackage"

# 2. Load class labels from YOLO
labels = model.names  # dict {0: 'cat', 1: 'dog', ...}
class_labels = [labels[i] for i in range(len(labels))]

# 3. Load the Core ML model spec
print("🔹 Loading Core ML model...")
mlmodel = ct.models.MLModel(mlpackage_path)
spec = mlmodel.get_spec()

# 4. Add classifier configuration
print("🔹 Embedding classifier metadata (top-1 prediction only)...")

spec.description.predictedFeatureName = "classLabel"
spec.description.predictedProbabilitiesName = "classLabelProbs"
for feature in spec.description.output:
    if feature.name == "classLabelProbs":
        feature.name = "classLabelProbs"
    elif feature.name == "classLabel":
        feature.name = "classLabel"

def _set_labels(spec, labels):
    model_type = spec.WhichOneof("Type")
    if model_type == "pipelineClassifier":
        for model_spec in spec.pipelineClassifier.pipeline.models:
            _set_labels(model_spec, labels)
    elif model_type == "pipeline":
        for model_spec in spec.pipeline.models:
            _set_labels(model_spec, labels)
    elif model_type == "neuralNetworkClassifier":
        labels_field = spec.neuralNetworkClassifier.stringClassLabels
        del labels_field.vector[:]
        labels_field.vector.extend(labels)
    elif model_type == "mlProgram":
        return
    else:
        raise ValueError(f"Unsupported model type: {model_type}")

desc = spec.description
prob_name = desc.predictedProbabilitiesName
if prob_name:
    for feature in desc.output:
        if feature.name == prob_name and feature.type.WhichOneof("Type") == "dictionaryType":
            key_kind = feature.type.dictionaryType.WhichOneof("KeyType")
            if key_kind == "stringKeyType":
                target = feature.type.dictionaryType.stringKeyType.vector
                del target[:]
                target.extend(class_labels)
            elif key_kind == "int64KeyType":
                target = feature.type.dictionaryType.int64KeyType.vector
                del target[:]
                target.extend(range(len(class_labels)))
_set_labels(spec, class_labels)

# 5. Save the updated model
output_path = "YOLOv8x-cls-top1.mlpackage"
weights_dir = os.path.join(mlpackage_path, "Data", "com.apple.CoreML", "weights")
ct.models.utils.save_spec(spec, output_path, weights_dir=weights_dir)

print(f"✅ Model saved as {output_path}")
print("Outputs: 'classLabel' (top prediction) and 'classLabelProbs' (probabilities).")
