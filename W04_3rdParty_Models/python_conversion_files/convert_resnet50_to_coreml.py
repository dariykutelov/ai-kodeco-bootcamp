import torch
import coremltools as ct
import json

print("🔹 Loading pretrained ResNet50...")
pt_model = torch.hub.load('pytorch/vision:v0.6.0', 'resnet50', pretrained=True)
pt_model.eval()

print("🔹 Loading ImageNet labels...")
with open("imagenet_labels.json", "r") as f:
    labels = json.load(f)

if isinstance(labels, dict):
    labels = [labels[str(i)] for i in range(len(labels))]

example_input = torch.rand(1, 3, 224, 224)
print("🔹 Tracing model...")
traced_model = torch.jit.trace(pt_model, example_input)

input_type = ct.ImageType(
    name="input_image",
    shape=example_input.shape,
    scale=1/255.0,
    bias=[0, 0, 0]
)

classifier_config = ct.ClassifierConfig(class_labels=labels)

print("🔹 Converting to Core ML (ML Program format)...")
mlmodel = ct.convert(
    traced_model,
    inputs=[input_type],
    classifier_config=classifier_config,
    minimum_deployment_target=ct.target.iOS15  # or ct.target.macOS12
)

output_path = "ResNet50.mlpackage"
mlmodel.save(output_path)

print(f"✅ Conversion complete! Saved as {output_path}")
