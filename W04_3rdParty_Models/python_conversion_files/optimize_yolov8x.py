from ultralytics import YOLO

model = YOLO("yolov8x-cls.pt")

model.export(format="coreml", int8=True, imgsz=(224, 224), name="yolov8x-cls-8")
print("Optimized YOLOv8x-cls model (int8) successfully exported to CoreML format as yolov8x-cls-8.mlpackage")

