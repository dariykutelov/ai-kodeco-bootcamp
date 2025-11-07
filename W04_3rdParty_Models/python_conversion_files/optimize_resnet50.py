import coremltools as ct
import coremltools.optimize as cto

orig_model = ct.models.MLModel("resnet50.mlpackage")

op_config = cto.coreml.OpLinearQuantizerConfig(
    mode="linear_symmetric", weight_threshold=512
)

config = cto.coreml.OptimizationConfig(global_config=op_config)

compressed_8_bit_model = cto.coreml.linear_quantize_weights(orig_model, config=config)

compressed_8_bit_model.save("resnet50-8.mlpackage")
print("Optimized ResNet50 model successfully saved as resnet50-8.mlpackage")

