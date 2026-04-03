//
//  BrowserToolbarView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct BrowserToolbarView: View {
    @Binding var searchText: String

    let tabs: [BrowserTab]
    let selectedTabID: BrowserTab.ID?
    let canGoBack: Bool
    let canGoForward: Bool
    let isLoading: Bool
    let isPrivateMode: Bool
    let onSubmit: () -> Void
    let onBack: () -> Void
    let onForward: () -> Void
    let onReload: () -> Void
    let onHome: () -> Void
    let onShowTabsOverview: () -> Void
    let onShowHistory: () -> Void
    let onShowAddPage: () -> Void
    let onTogglePrivateMode: () -> Void
    let onSelectTab: (BrowserTab.ID) -> Void
    let onCloseTab: (BrowserTab.ID) -> Void
    let onAddTab: () -> Void
    let onAddPrivateTab: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if isPrivateMode {
                    Button(action: onTogglePrivateMode) {
                        privateModeBadge
                    }
                    .buttonStyle(.plain)
                }

                reloadButton

                toolbarButton(
                    systemImage: "house.fill",
                    isEnabled: true,
                    action: onHome
                )

                toolbarButton(
                    systemImage: "square.grid.2x2",
                    isEnabled: true,
                    action: onShowTabsOverview
                )

                toolbarButton(
                    systemImage: "plus",
                    isEnabled: true,
                    action: onAddTab
                )

                toolbarButton(
                    systemImage: "chevron.left",
                    isEnabled: canGoBack,
                    action: onBack
                )

                toolbarButton(
                    systemImage: "chevron.right",
                    isEnabled: canGoForward,
                    action: onForward
                )

                menuButton
            }
            .padding(.horizontal, 2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.capsule)
    }

    private var privateModeBadge: some View {
        Image(systemName: "hand.raised.fill")
            .font(.system(size: 14, weight: .black))
            .frame(width: 40, height: 40)
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
            .clipShape(.capsule)
    }

    private var reloadButton: some View {
        Button(action: onReload) {
            Group {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(width: 40, height: 40)
            .background(.ultraThinMaterial)
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }

    private var menuButton: some View {
        Menu {
            Button(action: onShowHistory) {
                Label("History", systemImage: "clock.arrow.circlepath")
            }

            if !isPrivateMode {
                Button(action: onShowAddPage) {
                    Label("Seite hinzufuegen", systemImage: "doc.badge.plus")
                }
            }

            Button(action: onTogglePrivateMode) {
                Label(
                    isPrivateMode
                        ? "Private Mode ausschalten"
                        : "Private Mode einschalten",
                    systemImage: isPrivateMode ? "eye" : "eye.slash"
                )
            }

            Button(action: onAddPrivateTab) {
                Label("Neuer Private Tab", systemImage: "lock.fill")
            }
        } label: {
            Image(systemName: isPrivateMode ? "lock.fill" : "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 42, height: 42)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func toolbarButton(
        systemImage: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 35, height: 35)
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    PreviewContainer()
}

private struct PreviewContainer: View {
    @State private var searchText = "apple.com"
    private let tabs = [
        BrowserTab(initialURL: URL(string: "https://apple.com"))
    ]

    var body: some View {
        BrowserToolbarView(
            searchText: $searchText,
            tabs: tabs,
            selectedTabID: tabs.first?.id,
            canGoBack: true,
            canGoForward: false,
            isLoading: false,
            isPrivateMode: false,
            onSubmit: {},
            onBack: {},
            onForward: {},
            onReload: {},
            onHome: {},
            onShowTabsOverview: {},
            onShowHistory: {},
            onShowAddPage: {},
            onTogglePrivateMode: {},
            onSelectTab: { _ in },
            onCloseTab: { _ in },
            onAddTab: {},
            onAddPrivateTab: {}
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
