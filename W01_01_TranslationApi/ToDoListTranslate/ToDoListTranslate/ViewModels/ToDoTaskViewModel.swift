//
//  ViewModel.swift
//  ToDoListTranslate
//
//  Created by Dariy Kutelov on 13.10.25.
//

import Foundation
import Observation
import Translation
import NaturalLanguage

@Observable
class ToDoTaskViewModel {

    // MARK: - Properties
    
    var tasks: [ToDoTask] = [
        .init(id: "1", title: "犬の散歩をする", description: "朝に1回、仕事が終わった後に1回", status: .inProgress, priority: .low, createdAt: Date()),
        .init(id: "2", title: "食料品を買う", description: "最寄りのコンビニに行って、最も緊急の食料品を買う", status: .inProgress, priority: .medium, createdAt: Date()),
        .init(id: "3", title: "電気料金を支払う", description: "先月の電気料金をオンラインで支払う", status: .inProgress, priority: .high, createdAt: Date()),
        .init(id: "4", title: "Limpiar la casa", description: "Limpiar las ventanas de la sala", status: .inProgress, priority: .medium, createdAt: Date())
    ]
    var translateFrom: Locale.Language?
    var translateTo: Locale.Language?
    var availableLanguages: [AvailableLanguage] = []
    
    
    // MARK: - Init
    init() {
        prepareSupportedLanguages()
    }
    
    func prepareSupportedLanguages() {
        Task { @MainActor in
            let supportedLanguages = await LanguageAvailability().supportedLanguages
            availableLanguages = supportedLanguages.map {
                AvailableLanguage(locale: $0)
            }.sorted()
            
            setDefaultTargetLanguage()
            identifyLanguage()
        }
    }
    
    private func setDefaultTargetLanguage() {
        let deviceLanguage = Locale.current.language
        
        if let matchingLanguage = availableLanguages.first(where: { $0.locale == deviceLanguage }) {
            translateTo = matchingLanguage.locale
        } else if let matchingByCode = availableLanguages.first(where: { 
            $0.locale.languageCode == deviceLanguage.languageCode 
        }) {
            translateTo = matchingByCode.locale
        } else {
            translateTo = availableLanguages.first?.locale
        }
    }
    
    // MARK: - Task related methods
    func addTask(_ task: ToDoTask) {
        tasks.append(task)
        print(tasks)
    }
    
    func removeTask(_ taskId: String) {
        self.tasks.removeAll { $0.id == taskId }
    }
    
    // MARK: - Translation methods

    func translateSequence(using session: TranslationSession) async {
        var requests: [TranslationSession.Request] = []

        for (index, task) in tasks.enumerated() {
            requests.append(.init(sourceText: task.title, clientIdentifier: "title-\(index)"))
            requests.append(.init(sourceText: task.description, clientIdentifier: "desc-\(index)"))
        }

        do {
            for try await response in session.translate(batch: requests) {
                guard let identifier = response.clientIdentifier else { continue }
                let components = identifier.split(separator: "-")
                guard components.count == 2,
                      let index = Int(components[1]) else { continue }

                if components[0] == "title" {
                    tasks[index].title = response.targetText
                } else if components[0] == "desc" {
                    tasks[index].description = response.targetText
                }
            }
        } catch {
          print("Error executing translateSequence: \(error)")
        }
    }
    
    func identifyLanguage() {
        let translatableText = tasks.map { $0.title }.joined(separator: " ")
        print("Text to analyze: \(translatableText)")
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(translatableText)
        
        guard let detectedLanguage = recognizer.dominantLanguage else { 
            print("No language detected")
            translateFrom = nil
            return 
        }
        
        print("Detected language: \(detectedLanguage.rawValue)")
        
        let detectedLocale = Locale.Language(identifier: detectedLanguage.rawValue)
        print("Detected locale: \(detectedLocale)")
        print("Available languages count: \(availableLanguages.count)")
        
        if let matchingLanguage = availableLanguages.first(where: { $0.locale == detectedLocale }) {
            print("Found exact match: \(matchingLanguage.locale)")
            translateFrom = matchingLanguage.locale
        } else if let matchingByCode = availableLanguages.first(where: {
            let match = $0.locale.languageCode?.identifier == detectedLanguage.rawValue
            if match {
                print("Checking language code: \($0.locale.languageCode?.identifier ?? "nil") == \(detectedLanguage.rawValue)")
            }
            return match
        }) {
            print("Found match by language code: \(matchingByCode.locale)")
            translateFrom = matchingByCode.locale
        } else {
            print("No match found in available languages")
            print("First few available: \(availableLanguages.prefix(3).map { $0.locale })")
            translateFrom = nil
        }
        
        print("Final translateFrom: \(String(describing: translateFrom))")
    }
}
