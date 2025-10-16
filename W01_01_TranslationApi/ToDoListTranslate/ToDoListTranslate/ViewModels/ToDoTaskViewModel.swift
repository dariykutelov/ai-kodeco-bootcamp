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

//TODO: - Check if device language is in the allowed languages
//TODO: - Check if the identified language is in the allowed languages

@Observable
class ToDoTaskViewModel {

    // MARK: - Properties
    
    var tasks: [ToDoTask] = [
        .init(id: "1", title: "犬の散歩をする", description: "朝に1回、仕事が終わった後に1回", status: .inProgress, priority: .low, createdAt: Date()),
        .init(id: "2", title: "Позвони начальнику", description: "Скажи ему, что я не смогу завтра выйти на работу", status: .inProgress, priority: .low, createdAt: Date()),
        .init(id: "3", title: "食料品を買う", description: "最寄りのコンビニに行って、最も緊急の食料品を買う", status: .inProgress, priority: .medium, createdAt: Date()),
        .init(id: "4", title: "電気料金を支払う", description: "先月の電気料金をオンラインで支払う", status: .inProgress, priority: .high, createdAt: Date()),
        .init(id: "5", title: "Limpiar la casa", description: "Limpiar las ventanas de la sala", status: .inProgress, priority: .medium, createdAt: Date()),
        .init(id: "6", title: "Да заведа детето на лекар", description: "Утре сутринта да отидем до поликлинката при личната лекарка", status: .inProgress, priority: .medium, createdAt: Date()),
    ]

    var availableLanguages: [AvailableLanguage] = []
    var tasksByLanguage: [String: [ToDoTask]] = [:]
    
    // UI feedback properties
    var isDeviceLanguageSupported: Bool = true
    var unsupportedLanguages: [String] = []
    var translationStatusMessage: String = ""
    
    
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
            
            groupTasksByLanguage()
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
        let targetLanguage = Locale.current.language
        
        // Reset UI feedback
        isDeviceLanguageSupported = true
        unsupportedLanguages = []
        translationStatusMessage = ""
        
        // Check if device language is supported for translation
        guard await checkDeviceLanguageSupport(targetLanguage) else {
            isDeviceLanguageSupported = false
            let deviceLanguageName = getDeviceLanguageName(targetLanguage)
            translationStatusMessage = "Your device language (\(deviceLanguageName)) is not supported for translation."
            return
        }
        
        // Group tasks by language and check support
        let (supportedGroups, unsupportedLanguages) = await groupTasksByLanguageAndCheckSupport(targetLanguage)
        
        // Handle unsupported languages
        handleUnsupportedLanguages(unsupportedLanguages)
        
        // Translate supported language groups
        await translateLanguageGroups(session, groups: supportedGroups, targetLanguage: targetLanguage)
        
        // Update language grouping after translation
        groupTasksByLanguage()
    }
    
    // MARK: - Translation Helper Methods
    
    private func checkDeviceLanguageSupport(_ targetLanguage: Locale.Language) async -> Bool {
        // Check if we can translate TO the device language using all available languages
        for availableLanguage in availableLanguages {
            let status = await LanguageAvailability().status(from: availableLanguage.locale, to: targetLanguage)
            if status == .installed || status == .supported {
                print("✅ Device language (\(targetLanguage.languageCode?.identifier ?? "unknown")) is supported for translation")
                return true
            }
        }
        
        print("❌ Device language (\(targetLanguage.languageCode?.identifier ?? "unknown")) is not supported for translation")
        return false
    }
    
    private func groupTasksByLanguageAndCheckSupport(_ targetLanguage: Locale.Language) async -> (supportedGroups: [String: [(index: Int, task: ToDoTask)]], unsupportedLanguages: [String]) {
        var languageGroups: [String: [(index: Int, task: ToDoTask)]] = [:]
        var unsupportedLanguages: [String] = []
        
        for (index, task) in tasks.enumerated() {
            let detectedLanguage = identifyLanguageForText(task.title)
            let languageCode = detectedLanguage ?? "unknown"
            
            if languageCode != targetLanguage.languageCode?.identifier {
                let isSupported = await checkLanguageSupport(languageCode: languageCode, targetLanguage: targetLanguage)
                
                if isSupported {
                    if languageGroups[languageCode] == nil {
                        languageGroups[languageCode] = []
                    }
                    languageGroups[languageCode]?.append((index: index, task: task))
                } else {
                    unsupportedLanguages.append(languageCode)
                }
            }
        }
        
        return (languageGroups, unsupportedLanguages)
    }
    
    private func checkLanguageSupport(languageCode: String, targetLanguage: Locale.Language) async -> Bool {
        let detectedLocale = Locale.Language(identifier: languageCode)
        
        let status = await LanguageAvailability().status(from: detectedLocale, to: targetLanguage)
        print("Translation support for \(languageCode) -> \(targetLanguage.languageCode?.identifier ?? "unknown"): \(status)")
        
        switch status {
        case .installed, .supported:
            return true
        case .unsupported:
            print("⚠️ Translation not supported for \(languageCode)")
            return false
        @unknown default:
            print("⚠️ Unknown translation status for \(languageCode)")
            return false
        }
    }
    
    private func handleUnsupportedLanguages(_ unsupportedLanguages: [String]) {
        self.unsupportedLanguages = unsupportedLanguages
        
        if !unsupportedLanguages.isEmpty {
            print("❌ Cannot translate tasks in these languages: \(unsupportedLanguages.joined(separator: ", "))")
            print("These tasks will remain in their original language.")
            
            let languageNames = unsupportedLanguages.compactMap { code in
                getLanguageName(for: code)
            }
            
            translationStatusMessage = "Cannot translate tasks in: \(languageNames.joined(separator: ", ")). These tasks will remain in their original language."
        }
    }
    
    private func getLanguageName(for languageCode: String) -> String? {
        // Try to find in available languages first
        if let availableLanguage = availableLanguages.first(where: { 
            $0.locale.languageCode?.identifier == languageCode 
        }) {
            if let languageCode = availableLanguage.locale.languageCode?.identifier {
                let locale = Locale(identifier: languageCode)
                if let localizedName = locale.localizedString(forLanguageCode: languageCode), !localizedName.isEmpty {
                    return localizedName
                }
            }
        }
        
        // Fallback to system localization using Locale
        let locale = Locale(identifier: languageCode)
        if let localizedName = locale.localizedString(forLanguageCode: languageCode), !localizedName.isEmpty {
            return localizedName
        }
        
        // If all else fails, return the language code itself
        return languageCode
    }
    
    private func getDeviceLanguageName(_ language: Locale.Language) -> String {
        // Try to find in available languages first
        if let availableLanguage = availableLanguages.first(where: { $0.locale == language }) {
            if let languageCode = availableLanguage.locale.languageCode?.identifier {
                let locale = Locale(identifier: languageCode)
                if let localizedName = locale.localizedString(forLanguageCode: languageCode), !localizedName.isEmpty {
                    return localizedName
                }
            }
        }
        
        // Fallback to system localization
        if let languageCode = language.languageCode?.identifier {
            let locale = Locale(identifier: languageCode)
            if let localizedName = locale.localizedString(forLanguageCode: languageCode), !localizedName.isEmpty {
                return localizedName
            }
            return languageCode
        }
        
        return "Unknown"
    }
    
    private func translateLanguageGroups(_ session: TranslationSession, groups: [String: [(index: Int, task: ToDoTask)]], targetLanguage: Locale.Language) async {
        print("Translating \(groups.count) supported language groups to \(targetLanguage.languageCode?.identifier ?? "unknown")")
        
        for (languageCode, group) in groups {
            await translateLanguageGroup(session, languageCode: languageCode, group: group)
        }
        
        print("After translation, tasks are:")
        for (index, task) in tasks.enumerated() {
            print("Task \(index): '\(task.title)' - '\(task.description)'")
        }
    }
    
    private func translateLanguageGroup(_ session: TranslationSession, languageCode: String, group: [(index: Int, task: ToDoTask)]) async {
        print("Translating \(languageCode) group with \(group.count) tasks")
        
        var requests: [TranslationSession.Request] = []
        var taskIndexMap: [String: Int] = [:]
        
        for (originalIndex, task) in group {
            let titleId = "title-\(originalIndex)"
            let descId = "desc-\(originalIndex)"
            
            requests.append(.init(sourceText: task.title, clientIdentifier: titleId))
            requests.append(.init(sourceText: task.description, clientIdentifier: descId))
            
            taskIndexMap[titleId] = originalIndex
            taskIndexMap[descId] = originalIndex
        }
        
        do {
            for try await response in session.translate(batch: requests) {
                guard let identifier = response.clientIdentifier,
                      let index = taskIndexMap[identifier] else { continue }
                
                let components = identifier.split(separator: "-")
                guard components.count == 2 else { continue }

                print("Translated \(components[0]) for task \(index): '\(response.sourceText)' -> '\(response.targetText)'")

                if components[0] == "title" {
                    tasks[index].title = response.targetText
                } else if components[0] == "desc" {
                    tasks[index].description = response.targetText
                }
            }
        } catch {
            print("Error translating \(languageCode): \(error)")
        }
    }
    
    func groupTasksByLanguage() {
        tasksByLanguage.removeAll()
        
        for task in tasks {
            let detectedLanguage = identifyLanguageForText(task.title)
            let languageCode = detectedLanguage ?? "unknown"
            
            if tasksByLanguage[languageCode] == nil {
                tasksByLanguage[languageCode] = []
            }
            tasksByLanguage[languageCode]?.append(task)
        }
        
        print("Tasks grouped by language:")
        for (language, taskList) in tasksByLanguage {
            print("\(language): \(taskList.count) tasks")
        }
    }
    
    private func identifyLanguageForText(_ text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        guard let detectedLanguage = recognizer.dominantLanguage else { 
            return nil
        }
        
        let detectedLocale = Locale.Language(identifier: detectedLanguage.rawValue)
        
        if let matchingLanguage = availableLanguages.first(where: { $0.locale == detectedLocale }) {
            return matchingLanguage.locale.languageCode?.identifier
        } else if let matchingByCode = availableLanguages.first(where: {
            $0.locale.languageCode?.identifier == detectedLanguage.rawValue
        }) {
            return matchingByCode.locale.languageCode?.identifier
        } else {
            return detectedLanguage.rawValue
        }
    }
}
