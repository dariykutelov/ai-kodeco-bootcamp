import urllib.request
import tensorflow as tf
import coremltools as ct

label_url = "https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt"
raw_labels = urllib.request.urlopen(label_url).read().splitlines()
class_labels = []
for idx, label in enumerate(raw_labels):
    if idx == 0:
        continue
    if isinstance(label, bytes):
        class_labels.append(label.decode("utf8"))
    else:
        class_labels.append(label)

keras_model = tf.keras.applications.MobileNetV2(weights="imagenet", input_shape=(224, 224, 3), classes=1000)

image_input = ct.ImageType(shape=(1, 224, 224, 3), bias=[-1, -1, -1], scale=1 / 127)
classifier_config = ct.ClassifierConfig(class_labels)

mlmodel = ct.convert(keras_model, inputs=[image_input], classifier_config=classifier_config)

mlmodel.input_description["input_1"] = "Input image to be classified"
mlmodel.output_description["classLabel"] = "Most likely image category"
mlmodel.author = "Original Paper: Mark Sandler, Andrew Howard, Menglong Zhu, Andrey Zhmoginov, Liang-Chieh Chen"
mlmodel.license = "See https://github.com/tensorflow/tensorflow and https://github.com/tensorflow/models/tree/master/research/slim/nets/mobilenet for license information."
mlmodel.short_description = "Detects the dominant objects present in an image from a set of 1000 categories."
mlmodel.user_defined_metadata["com.apple.coreml.model.preview.type"] = "imageClassifier"
mlmodel.version = "2.0"

mlmodel.save("MobileNetV2.mlpackage")
print("MobileNetV2.mlpackage saved")

