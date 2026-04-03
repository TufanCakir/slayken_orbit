//
//  SavedPagesView.swift
//  Slayken Orbit
//

import SwiftUI

struct SavedPagesView: View {
    let pages: [SavedPage]
    let onOpen: (SavedPage) -> Void
    let onDelete: (SavedPage.ID) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if pages.isEmpty {
                    ContentUnavailableView(
                        "Keine gespeicherten Seiten",
                        systemImage: "bookmark",
                        description: Text(
                            "Gespeicherte Link- oder HTML-Seiten werden hier gesammelt."
                        )
                    )
                } else {
                    List {
                        ForEach(pages) { page in
                            Button {
                                onOpen(page)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text(page.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)

                                        Label(
                                            page.kind == .link ? "Link" : "HTML",
                                            systemImage: page.kind == .link ? "link" : "chevron.left.forwardslash.chevron.right"
                                        )
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                    }

                                    Text(subtitle(for: page))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)

                                    Text(
                                        page.createdAt.formatted(
                                            date: .abbreviated,
                                            time: .shortened
                                        )
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                            .swipeActions {
                                Button(role: .destructive) {
                                    onDelete(page.id)
                                } label: {
                                    Label("Loeschen", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Gespeicherte Seiten")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Schliessen") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func subtitle(for page: SavedPage) -> String {
        switch page.kind {
        case .link:
            return page.link ?? "Gespeicherter Link"
        case .html:
            return "Lokale HTML-Seite"
        }
    }
}

#Preview {
    SavedPagesView(
        pages: [
            SavedPage(
                title: "OpenAI",
                kind: .link,
                link: "https://openai.com"
            ),
            SavedPage(
                title: "Landing Page",
                kind: .html,
                html: "<html><body><h1>Hello</h1></body></html>"
            )
        ],
        onOpen: { _ in },
        onDelete: { _ in }
    )
}
