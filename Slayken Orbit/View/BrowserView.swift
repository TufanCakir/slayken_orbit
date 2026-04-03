//
//  BrowserView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct BrowserView: View {
    @StateObject private var viewModel = BrowserViewModel()

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 16) {
                if let selectedTab = viewModel.selectedTab {
                    if selectedTab.isShowingStartPage {
                        contentShell {
                            BrowserStartView(
                                searchText: $viewModel.searchText,
                                onSubmit: viewModel.submitSearch
                            )
                        } toolbar: {
                            startToolbar(for: selectedTab)
                        }
                    } else {
                        browserContent(for: selectedTab)
                    }
                } else {
                    ContentUnavailableView(
                        "Kein Tab ausgewahlt",
                        systemImage: "square.on.square",
                        description: Text(
                            "Erstelle einen neuen Tab, um eine Seite zu laden."
                        )
                    )
                }
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.isHistoryPresented) {
            HistoryView(
                entries: viewModel.history,
                onSelect: viewModel.openHistoryEntry,
                onClear: viewModel.clearHistory
            )
        }
        .sheet(isPresented: $viewModel.isTabsOverviewPresented) {
            BrowserTabsOverviewView(
                tabs: viewModel.tabs,
                selectedTabID: viewModel.selectedTabID,
                onSelectTab: viewModel.selectTabFromOverview,
                onCloseTab: viewModel.closeTab,
                onAddTab: viewModel.addTabFromOverview,
                onAddPrivateTab: viewModel.addPrivateTabFromOverview,
                onDismiss: viewModel.hideTabsOverview
            )
        }
    }

    @ViewBuilder
    private func browserContent(for selectedTab: BrowserTab) -> some View {
        contentShell {
            BrowserWebView(
                tab: selectedTab,
                onVisitRecorded: viewModel.recordVisit
            )
            .id(selectedTab.id)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
        } toolbar: {
            browserToolbar(for: selectedTab)
        }
    }

    private func startToolbar(for selectedTab: BrowserTab) -> some View {
        BrowserToolbarView(
            searchText: $viewModel.searchText,
            tabs: viewModel.tabs,
            selectedTabID: viewModel.selectedTabID,
            canGoBack: false,
            canGoForward: false,
            isLoading: false,
            isPrivateMode: selectedTab.isPrivateMode,
            onSubmit: viewModel.submitSearch,
            onBack: {},
            onForward: {},
            onReload: {},
            onHome: viewModel.openHomePage,
            onShowTabsOverview: viewModel.showTabsOverview,
            onShowHistory: viewModel.showHistory,
            onTogglePrivateMode: viewModel.togglePrivateModeForSelectedTab,
            onSelectTab: viewModel.selectTab,
            onCloseTab: viewModel.closeTab,
            onAddTab: viewModel.addTab,
            onAddPrivateTab: viewModel.addPrivateTab
        )
    }

    private func browserToolbar(for selectedTab: BrowserTab) -> some View {
        BrowserToolbarView(
            searchText: $viewModel.searchText,
            tabs: viewModel.tabs,
            selectedTabID: viewModel.selectedTabID,
            canGoBack: selectedTab.canGoBack,
            canGoForward: selectedTab.canGoForward,
            isLoading: selectedTab.isLoading,
            isPrivateMode: selectedTab.isPrivateMode,
            onSubmit: viewModel.submitSearch,
            onBack: viewModel.goBack,
            onForward: viewModel.goForward,
            onReload: viewModel.reload,
            onHome: viewModel.openHomePage,
            onShowTabsOverview: viewModel.showTabsOverview,
            onShowHistory: viewModel.showHistory,
            onTogglePrivateMode: viewModel.togglePrivateModeForSelectedTab,
            onSelectTab: viewModel.selectTab,
            onCloseTab: viewModel.closeTab,
            onAddTab: viewModel.addTab,
            onAddPrivateTab: viewModel.addPrivateTab
        )
    }

    private func contentShell<Content: View, Toolbar: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder toolbar: () -> Toolbar
    ) -> some View {
        VStack(spacing: 16) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            toolbar()
        }
    }

    private var backgroundView: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }
}

#Preview {
    BrowserView()
}
