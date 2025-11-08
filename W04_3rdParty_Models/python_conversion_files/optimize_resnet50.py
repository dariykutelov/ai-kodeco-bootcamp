import os
import coremltools as ct
import coremltools.optimize as cto

# Load FP32 CoreML ML Program model
input_path = "ResNet50.mlpackage"
print(f"🔹 Loading base model: {input_path}")

model_fp32 = ct.models.MLModel(input_path)

# Create INT8 quantization configuration
print("🔹 Creating INT8 quantization config...")

# Symmetric 8-bit quantization (best for speed/accuracy balance)
op_config = cto.coreml.OpLinearQuantizerConfig(
    mode="linear_symmetric"
)

opt_config = cto.coreml.OptimizationConfig(global_config=op_config)

# Apply weight quantization
print("🔹 Applying linear INT8 quantization...")

model_int8 = cto.coreml.linear_quantize_weights(
    model_fp32,
    config=opt_config
)

output_path = "ResNet50-int8.mlpackage"
model_int8.save(output_path)

print(f"✅ Saved optimized model: {output_path}")

# Print size comparison
def model_size(path):
    return os.path.getsize(path) / (1024 * 1024)

print("\n📊 Model size comparison (MB):")
print(f"• FP32: {model_size(input_path):.2f} MB")
print(f"• INT8: {model_size(output_path):.2f} MB")

print("\n✅ Optimization complete.")
