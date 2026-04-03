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
    let onTogglePrivateMode: () -> Void
    let onSelectTab: (BrowserTab.ID) -> Void
    let onCloseTab: (BrowserTab.ID) -> Void
    let onAddTab: () -> Void
    let onAddPrivateTab: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 16) {
                Button(action: onReload) {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(.ultraThinMaterial)

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
                systemImage: "chevron.left",
                isEnabled: canGoBack,
                action: onBack
            )

            toolbarButton(
                systemImage: "chevron.right",
                isEnabled: canGoForward,
                action: onForward
            )

            BrowserTabsMenuView(
                tabs: tabs,
                selectedTabID: selectedTabID,
                onSelect: onSelectTab,
                onClose: onCloseTab,
                onAdd: onAddTab
            )

            Menu {
                Button(action: onShowHistory) {
                    Label("History", systemImage: "clock.arrow.circlepath")
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
        .padding(14)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 18, y: 8)
    }

    private func toolbarButton(
        systemImage: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Capsule())
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
