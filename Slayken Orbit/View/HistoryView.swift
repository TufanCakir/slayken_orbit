//
//  HistoryView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct HistoryView: View {
    let entries: [BrowserHistoryEntry]
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
                                "Besuchte Seiten werden hier angezeigt."
                            )
                        )
                    } else {
                        List(entries) { entry in
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
}
