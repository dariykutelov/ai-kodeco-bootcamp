import os
from ultralytics import YOLO
import coremltools as ct

model = YOLO("yolov8x-cls.pt")
model.export(format="coreml", imgsz=(224, 224), name="yolov8x-cls")
mlpackage_path = "yolov8x-cls.mlpackage"
mlmodel = ct.models.MLModel(mlpackage_path)
spec = mlmodel.get_spec()
output_path = "yolov8x-cls-converted.mlpackage"
weights_dir = os.path.join(mlpackage_path, "Data", "com.apple.CoreML", "weights")
ct.models.utils.save_spec(spec, output_path, weights_dir=weights_dir)
print(f"Model saved as {output_path}")
