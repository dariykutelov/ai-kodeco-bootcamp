//
//  ImageClassifier.swift
//  ImageClassificationApp
//
//  Created by Dariy Kutelov on 7.11.25.
//

import SwiftUI
import Vision
import CoreML

enum SelectedModel {
    case yolov8x_cls_converted
    case yolov8x_cls_int8
    case ResNet50
    case ResNet50_int8
    case MobileNetV2
}


final class ImageClassifier {
    
    // MARK: - Props
    
    private let selectedModel: SelectedModel
    private var model: MLModel?
    
    
    // MARK: - Init
    
    init(selectedModel: SelectedModel) {
        self.selectedModel = selectedModel
        
        switch selectedModel {
        case .yolov8x_cls_converted:
            self.model = try? yolov8x_cls_converted(configuration: .init()).model
        case .yolov8x_cls_int8:
            self.model = try? yolov8x_cls_int8(configuration: .init()).model
        case .ResNet50:
            self.model = try? ResNet50(configuration: .init()).model
        case .ResNet50_int8:
            self.model = try? ResNet50_int8(configuration: .init()).model
        case .MobileNetV2:
            self.model = try? MobileNetV2(configuration: .init()).model
        }
    }
    
    
    // MARK: Clasify Image
    
    func classify(image: UIImage) -> (String, Float)? {
        guard let model else { return nil }
        guard let cgImage = image.cgImage else { return nil }
        guard let input = model.modelDescription.inputDescriptionsByName.first else { return nil }
        guard let constraint = input.value.imageConstraint else { return nil }
        guard let featureValue = try? MLFeatureValue(cgImage: cgImage, constraint: constraint) else { return nil }
        guard let provider = try? MLDictionaryFeatureProvider(dictionary: [input.key: featureValue]) else { return nil }
        guard let output = try? model.prediction(from: provider) else { return nil }
        
        let normalize = requiresNormalization()
        
        if let probabilitiesName = model.modelDescription.predictedProbabilitiesName {
            let probabilitiesFeature = output.featureValue(for: probabilitiesName)
            if let value = probabilitiesFeature?.dictionaryValue as? [String: NSNumber] {
                if let label = getLabel(from: value),
                   let probability = getProbability(for: value, label: label, normalize: normalize) {
                    return (label, probability)
                }
            }
        }
        
        if let name = model.modelDescription.predictedProbabilitiesName,
           let value = output.featureValue(for: name)?.dictionaryValue as? [String: NSNumber],
           let label = getLabel(from: value),
           let probability = getProbability(for: value, label: label, normalize: normalize) {
            return (label, probability)
        }
        
        if let name = model.modelDescription.predictedFeatureName,
           let value = output.featureValue(for: name) {
            if value.type == .string {
                return (value.stringValue, 1)
            }
            if value.type == .dictionary,
               let dict = value.dictionaryValue as? [String: NSNumber],
               let label = getLabel(from: dict),
               let probability = getProbability(for: dict, label: label, normalize: normalize) {
                return (label, probability)
            }
        }
        return nil
    }
    
    
    // MARK: Helpers
    
    private func getLabel(from dictionary: [String: NSNumber]) -> String? {
        dictionary.max(by: { $0.value.floatValue < $1.value.floatValue })?.key
    }
    
    private func getProbability(for dictionary: [String: NSNumber], label: String, normalize: Bool) -> Float? {
        let floats = dictionary.mapValues { $0.floatValue }
        guard let value = floats[label] else { return nil }
        if !normalize {
            return value
        }
        guard let maxValue = floats.values.max() else { return nil }
        let expValues = floats.mapValues { exp($0 - maxValue) }
        let sum = expValues.values.reduce(0, +)
        guard sum > 0, let normalizedValue = expValues[label] else { return nil }
        return normalizedValue / sum
    }
    
    private func requiresNormalization() -> Bool {
        switch selectedModel {
        case .ResNet50:
            return true
        case .ResNet50_int8:
            return true
        default:
            return false
        }
    }
}
