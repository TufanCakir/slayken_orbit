//
//  HistoryView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct HistoryView: View {
    let entries: [BrowserHistoryEntry]
    let isPrivateMode: Bool
    let onSelect: (BrowserHistoryEntry) -> Void
    let onClear: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            NavigationStack {
                Group {
                    if entries.isEmpty {
                        ContentUnavailableView(
                            "Keine History",
                            systemImage: "clock.arrow.circlepath",
                            description: Text(
                                isPrivateMode
                                    ? "Incognito ist aktiv. In diesem Modus wird kein neuer Verlauf gespeichert."
                                    : "Besuchte Seiten werden hier angezeigt."
                            )
                        )
                    } else {
                        List {
                            if isPrivateMode {
                                Section {
                                    incognitoBanner
                                        .listRowBackground(Color.clear)
                                }
                            }

                            ForEach(entries) { entry in
                                Button {
                                    onSelect(entry)
                                    dismiss()
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(entry.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)

                                        Text(entry.url.absoluteString)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)

                                        Text(
                                            entry.visitedAt.formatted(
                                                date: .abbreviated,
                                                time: .shortened
                                            )
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                    }

                                    .padding()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Schliessen") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Leeren") {
                            onClear()
                        }
                        .disabled(entries.isEmpty)
                    }
                }
            }
        }
    }

    private var incognitoBanner: some View {
        Label(
            "INCOGNITO aktiv. Neue Seiten aus diesem Modus werden nicht im Verlauf gespeichert.",
            systemImage: "hand.raised.fill"
        )
        .font(.headline.weight(.bold))
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.17, green: 0.12, blue: 0.24),
                    Color(red: 0.07, green: 0.07, blue: 0.12),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
