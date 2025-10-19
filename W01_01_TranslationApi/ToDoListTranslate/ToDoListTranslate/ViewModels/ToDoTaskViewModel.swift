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
        .init(id: "4", title: "Limpiar la casa", description: "Limpiar las ventanas de la sala", status: .inProgress, priority: .medium, createdAt: Date()),
        .init(id: "5", title: "Позвони начальнику", description: "Скажи ему, что я не смогу завтра выйти на работу", status: .inProgress, priority: .low, createdAt: Date()),
        .init(id: "6", title: "Да заведа детето на лекар", description: "Утре сутринта да отидем до поликлинката при личната лекарка", status: .inProgress, priority: .medium, createdAt: Date()),
    ]
    var tasksByLanguage: [String: [ToDoTask]] = [:]
    var availableLanguages: [AvailableLanguage] = []
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
    
    
    // MARK: - Add and Remove tasks
    
    func addTask(_ task: ToDoTask) {
        tasks.append(task)
    }
    
    func removeTask(_ taskId: String) {
        self.tasks.removeAll { $0.id == taskId }
    }
    
    // MARK: - Translation methods
    
    func translateSequence(using session: TranslationSession) async {
        let targetLanguage = Locale.current.language
        isDeviceLanguageSupported = true
        unsupportedLanguages = []
        translationStatusMessage = ""
        
        guard await checkDeviceLanguageSupport(targetLanguage) else {
            isDeviceLanguageSupported = false
            let deviceLanguageName = getDeviceLanguageName(targetLanguage)
            translationStatusMessage = "Your device language (\(deviceLanguageName)) is not supported for translation."
            return
        }
        
        let (supportedGroups, unsupportedLanguages) = await groupTasksByLanguageAndCheckSupport(targetLanguage)
        handleUnsupportedLanguages(unsupportedLanguages)
        
        for (languageCode, group) in supportedGroups {
            await translateLanguageGroup(session, languageCode: languageCode, group: group)
        }
        groupTasksByLanguage()
    }
    
    private func translateLanguageGroup(_ session: TranslationSession, languageCode: String, group: [(index: Int, task: ToDoTask)]) async {
        let titles = group.map { $0.task.title }
        let descriptions = group.map { $0.task.description }
        
        let combinedTitles = titles.joined(separator: " ||| ")
        let combinedDescriptions = descriptions.joined(separator: " ||| ")
        
        let requests = [
            TranslationSession.Request(sourceText: combinedTitles, clientIdentifier: "titles"),
            TranslationSession.Request(sourceText: combinedDescriptions, clientIdentifier: "descriptions")
        ]
        
        do {
            var translatedTitles: [String] = []
            var translatedDescriptions: [String] = []
            
            for try await response in session.translate(batch: requests) {
                guard let identifier = response.clientIdentifier else { continue }
                
                if identifier == "titles" {
                    translatedTitles = response.targetText.components(separatedBy: " ||| ")
                } else if identifier == "descriptions" {
                    translatedDescriptions = response.targetText.components(separatedBy: " ||| ")
                }
            }
            
            for (i, (originalIndex, _)) in group.enumerated() {
                if i < translatedTitles.count {
                    tasks[originalIndex].title = translatedTitles[i]
                }
                if i < translatedDescriptions.count {
                    tasks[originalIndex].description = translatedDescriptions[i]
                }
            }
            
        } catch {
            print("Error translating \(languageCode): \(error)")
        }
    }
    
    
    // MARK: - Translation Helper Methods
    
    private func checkDeviceLanguageSupport(_ targetLanguage: Locale.Language) async -> Bool {
        for availableLanguage in availableLanguages {
            let status = await LanguageAvailability().status(from: availableLanguage.locale, to: targetLanguage)
            if status == .installed || status == .supported {
                return true
            }
        }
        
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
            let languageNames = unsupportedLanguages.compactMap { code in
                getLanguageName(for: code)
            }
            
            translationStatusMessage = "Cannot translate tasks in: \(languageNames.joined(separator: ", ")). These tasks will remain in their original language."
        }
    }
    
    private func getLanguageName(for languageCode: String) -> String? {
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
        
        let locale = Locale(identifier: languageCode)
        if let localizedName = locale.localizedString(forLanguageCode: languageCode), !localizedName.isEmpty {
            return localizedName
        }
        
        return languageCode
    }
    
    private func getDeviceLanguageName(_ language: Locale.Language) -> String {
        if let availableLanguage = availableLanguages.first(where: { $0.locale == language }) {
            if let languageCode = availableLanguage.locale.languageCode?.identifier {
                let locale = Locale(identifier: languageCode)
                if let localizedName = locale.localizedString(forLanguageCode: languageCode), !localizedName.isEmpty {
                    return localizedName
                }
            }
        }
        
        if let languageCode = language.languageCode?.identifier {
            let locale = Locale(identifier: languageCode)
            if let localizedName = locale.localizedString(forLanguageCode: languageCode), !localizedName.isEmpty {
                return localizedName
            }
            return languageCode
        }
        
        return "Unknown"
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
