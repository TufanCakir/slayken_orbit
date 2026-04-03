//
//  AddPageView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct AddPageView: View {
    let isPrivateMode: Bool
    let onAddLink: (String, Bool, Bool) -> Void
    let onAddHTML: (String, String, Bool, Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var inputMode: AddPageInputMode = .link
    @State private var linkText = ""
    @State private var pageTitle = ""
    @State private var htmlText = ""
    @State private var opensInNewTab = true
    @State private var shouldSavePage = true

    var body: some View {
        NavigationStack {
            Form {
                if isPrivateMode {
                    Section {
                        Label(
                            "Neue Inhalte werden im aktuellen Incognito-Kontext geoeffnet.",
                            systemImage: "hand.raised.fill"
                        )
                        .font(.headline)
                    }
                }

                Section {
                    Picker("Typ", selection: $inputMode) {
                        ForEach(AddPageInputMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Ziel") {
                    Toggle("In neuem Tab oeffnen", isOn: $opensInNewTab)
                }

                if !isPrivateMode {
                    Section("Speichern") {
                        Toggle(
                            "Seite dauerhaft speichern",
                            isOn: $shouldSavePage
                        )
                    }
                }

                switch inputMode {
                case .link:
                    Section("Link") {
                        TextField("https://deine-seite.de", text: $linkText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Text(
                            "Du kannst auch nur eine Domain wie `google.com` eingeben."
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                case .html:
                    Section("HTML-Titel") {
                        TextField("Meine Seite", text: $pageTitle)
                    }

                    Section("HTML-Code") {
                        TextEditor(text: $htmlText)
                            .frame(minHeight: 220)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .navigationTitle("Seite hinzufuegen")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Hinzufuegen") {
                        submit()
                    }
                    .disabled(!canSubmit)
                }
            }
        }
    }

    private var canSubmit: Bool {
        switch inputMode {
        case .link:
            return !linkText.trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        case .html:
            return !htmlText.trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        }
    }

    private func submit() {
        switch inputMode {
        case .link:
            onAddLink(linkText, opensInNewTab, shouldSavePage)
        case .html:
            onAddHTML(pageTitle, htmlText, opensInNewTab, shouldSavePage)
        }
    }
}

private enum AddPageInputMode: String, CaseIterable, Identifiable {
    case link
    case html

    var id: String { rawValue }

    var title: String {
        switch self {
        case .link:
            return "Link"
        case .html:
            return "HTML"
        }
    }
}

#Preview {
    AddPageView(
        isPrivateMode: false,
        onAddLink: { _, _, _ in },
        onAddHTML: { _, _, _, _ in }
    )
}
