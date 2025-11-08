import os
from ultralytics import YOLO
import coremltools as ct
import coremltools.optimize as cto

# Export YOLOv8 classification model → CoreML FP32
print("🔹 Exporting YOLOv8x classification model → CoreML FP32...")

model = YOLO("yolov8x-cls.pt")
model.export(
    format="coreml",
    nms=False,
    imgsz=224,
    name="yolov8x-cls"
)

fp32_path = "yolov8x-cls.mlpackage"
print(f"✅ Exported FP32 model: {fp32_path}\n")

model_fp32 = ct.models.MLModel(fp32_path)

# Apply INT8 weight quantization
print("🔹 Applying 8-bit Linear Quantization (CoreMLTools 7+)...")

op_config = cto.coreml.OpLinearQuantizerConfig(
    mode="linear_symmetric"
)
opt_config = cto.coreml.OptimizationConfig(global_config=op_config)

model_int8 = cto.coreml.linear_quantize_weights(
    model_fp32,
    config=opt_config
)

int8_path = "yolov8x-cls-int8.mlpackage"
model_int8.save(int8_path)

print(f"✅ Saved INT8 quantized model: {int8_path}\n")

# Show model sizes
def model_size(path):
    return os.path.getsize(path) / (1024 * 1024)

print("📊 Model size comparison (MB):")
print(f"• FP32: {model_size(fp32_path):.2f} MB")
print(f"• INT8: {model_size(int8_path):.2f} MB")

print("\n✅ Optimization completed successfully.")
