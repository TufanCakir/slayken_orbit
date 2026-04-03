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
                        contentShell(isPrivateMode: selectedTab.isPrivateMode) {
                            BrowserStartView(
                                searchText: $viewModel.searchText,
                                isPrivateMode: selectedTab.isPrivateMode,
                                onSubmit: viewModel.submitSearch,
                                onShowAddPage: viewModel.showAddPage
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
                isPrivateMode: viewModel.selectedTab?.isPrivateMode == true,
                onSelect: viewModel.openHistoryEntry,
                onClear: viewModel.clearHistory
            )
        }
        .sheet(isPresented: $viewModel.isTabsOverviewPresented) {
            BrowserTabsOverviewView(
                tabs: viewModel.tabs,
                selectedTabID: viewModel.selectedTabID,
                isPrivateMode: viewModel.selectedTab?.isPrivateMode == true,
                onSelectTab: viewModel.selectTabFromOverview,
                onCloseTab: viewModel.closeTab,
                onAddTab: viewModel.addTabFromOverview,
                onAddPrivateTab: viewModel.addPrivateTabFromOverview,
                onDismiss: viewModel.hideTabsOverview
            )
        }
        .sheet(isPresented: $viewModel.isAddPagePresented) {
            AddPageView(
                isPrivateMode: viewModel.selectedTab?.isPrivateMode == true,
                onAddLink: viewModel.addPageFromLink,
                onAddHTML: viewModel.addPageFromHTML
            )
        }
        .sheet(isPresented: $viewModel.isSavedPagesPresented) {
            SavedPagesView(
                pages: viewModel.savedPages,
                onOpen: viewModel.openSavedPage,
                onDelete: viewModel.deleteSavedPage
            )
        }
    }

    @ViewBuilder
    private func browserContent(for selectedTab: BrowserTab) -> some View {
        contentShell(isPrivateMode: selectedTab.isPrivateMode) {
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
            canGoForward: selectedTab.lastContentURL != nil,
            isLoading: false,
            isPrivateMode: selectedTab.isPrivateMode,
            onSubmit: viewModel.submitSearch,
            onBack: viewModel.goBack,
            onForward: viewModel.goForward,
            onReload: {},
            onHome: viewModel.openHomePage,
            onShowTabsOverview: viewModel.showTabsOverview,
            onShowHistory: viewModel.showHistory,
            onShowAddPage: viewModel.showAddPage,
            onShowSavedPages: viewModel.showSavedPages,
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
            canGoBack: selectedTab.canGoBack || !selectedTab.isShowingStartPage,
            canGoForward: selectedTab.canGoForward
                || selectedTab.isShowingStartPage
                    && selectedTab.lastContentURL != nil,
            isLoading: selectedTab.isLoading,
            isPrivateMode: selectedTab.isPrivateMode,
            onSubmit: viewModel.submitSearch,
            onBack: viewModel.goBack,
            onForward: viewModel.goForward,
            onReload: viewModel.reload,
            onHome: viewModel.openHomePage,
            onShowTabsOverview: viewModel.showTabsOverview,
            onShowHistory: viewModel.showHistory,
            onShowAddPage: viewModel.showAddPage,
            onShowSavedPages: viewModel.showSavedPages,
            onTogglePrivateMode: viewModel.togglePrivateModeForSelectedTab,
            onSelectTab: viewModel.selectTab,
            onCloseTab: viewModel.closeTab,
            onAddTab: viewModel.addTab,
            onAddPrivateTab: viewModel.addPrivateTab
        )
    }

    private func contentShell<Content: View, Toolbar: View>(
        isPrivateMode: Bool = false,
        @ViewBuilder content: () -> Content,
        @ViewBuilder toolbar: () -> Toolbar
    ) -> some View {
        VStack(spacing: 16) {
            if isPrivateMode {
                privateModeBanner
            }

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            toolbar()
        }
    }

    private var backgroundView: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }

    private var privateModeBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Color.black.opacity(0.18), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("INCOGNITO")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(
                    "Privater Modus aktiv. Verlauf und Vorschauen werden nicht gespeichert."
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
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
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    BrowserView()
}
