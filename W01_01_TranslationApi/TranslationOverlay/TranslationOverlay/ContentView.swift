//
//  ContentView.swift
//  TranslationOverlay
//
//  Created by Dariy Kutelov on 13.10.25.
//

import SwiftUI
import Observation
import Translation

struct ContentView: View {
    @State private var translatableText: String = ""
    @State private var showTranslation: Bool = false
    
    private var isFormValid: Bool {
        !translatableText.isEmptyOrWhitespace
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Text", text: $translatableText,
                          prompt: Text("Enter text here"),
                          axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(5...10)
                    .padding()
                
                Button {
                    showTranslation.toggle()
                    UIAccessibility.post(notification: .announcement,
                         argument: "Text translated")
                } label: {
                    Text("Translate")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Translate Button")
                .accessibilityHint("Translates the text in the text field")
                .accessibilityAddTraits(.isButton)
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1 : 0.7)
            }
            .navigationTitle(Text("Translate Text"))
            .translationPresentation(
                isPresented: $showTranslation,
                text: translatableText,
                replacementAction: { translatedText in
                    translatableText = translatedText
            })
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}

extension String {
    var isEmptyOrWhitespace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
