//
//  BrowserTabsOverviewView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct BrowserTabsOverviewView: View {
    let tabs: [BrowserTab]
    let selectedTabID: BrowserTab.ID?
    let onSelectTab: (BrowserTab.ID) -> Void
    let onCloseTab: (BrowserTab.ID) -> Void
    let onAddTab: () -> Void
    let onAddPrivateTab: () -> Void
    let onDismiss: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(tabs) { tab in
                                BrowserTabOverviewCard(
                                    tab: tab,
                                    isSelected: tab.id == selectedTabID,
                                    onSelect: {
                                        onSelectTab(tab.id)
                                    },
                                    onClose: {
                                        onCloseTab(tab.id)
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fertig") {
                        onDismiss()
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Deine Tabs")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(.primary)

            Text(
                "Wechsle direkt zwischen deinen Tabs, schließe ungenutzte Seiten oder starte einen neuen Tab."
            )
            .font(.headline)
            .foregroundStyle(.primary)

            HStack(spacing: 12) {
                overviewActionButton(
                    title: "Neuer Tab",
                    systemImage: "plus",
                    action: onAddTab
                )

                overviewActionButton(
                    title: "Privater Tab",
                    systemImage: "lock.fill",
                    action: onAddPrivateTab
                )
            }
        }
    }

    private func overviewActionButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline.weight(.bold))
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }
}

private struct BrowserTabOverviewCard: View {
    @ObservedObject var tab: BrowserTab

    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .topTrailing) {
                previewContent

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 28, height: 28)
                        .background(.ultraThinMaterial)
                        .clipShape(.capsule)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(tab.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if tab.isPrivateMode {
                        Image(systemName: "lock.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                }

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Button(action: onSelect) {
                Text(isSelected ? "Aktiver Tab" : "Tab öffnen")
                    .font(.subheadline.weight(.bold))
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.capsule)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.ultraThinMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    isSelected
                        ? Color.white.opacity(0.45) : Color.white.opacity(0.12),
                    lineWidth: isSelected ? 2 : 1
                )
        }
    }

    private var subtitle: String {
        if tab.isShowingStartPage {
            return "Startseite"
        }

        return tab.currentURL?.host ?? "Seite"
    }

    private var cardBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(isSelected ? 0.22 : 0.14),
                Color.white.opacity(0.08),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var previewContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.08))

            if let previewImage = tab.previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
            } else {
                VStack(spacing: 10) {
                    Image(
                        systemName: tab.isShowingStartPage
                            ? "sparkles" : "globe.europe.africa.fill"
                    )
                    .font(.system(size: 28, weight: .bold))

                    Text(
                        tab.isShowingStartPage
                            ? "Startansicht" : "Vorschau folgt"
                    )
                    .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color.white.opacity(0.8))
            }
        }
        .aspectRatio(0.75, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    BrowserTabsOverviewView(
        tabs: [
            BrowserTab(initialURL: URL(string: "https://apple.com")),
            BrowserTab(isPrivateMode: true),
        ],
        selectedTabID: nil,
        onSelectTab: { _ in },
        onCloseTab: { _ in },
        onAddTab: {},
        onAddPrivateTab: {},
        onDismiss: {}
    )
}
