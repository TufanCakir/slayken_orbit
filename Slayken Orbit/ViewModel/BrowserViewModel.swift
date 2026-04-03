//
//  BrowserViewModel.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import Combine
import Foundation
import WebKit

@MainActor
final class BrowserViewModel: ObservableObject {
    @Published private(set) var tabs: [BrowserTab] = []
    @Published var selectedTabID: BrowserTab.ID?
    @Published var searchText = ""
    @Published private(set) var history: [BrowserHistoryEntry] = []
    @Published var isHistoryPresented = false
    @Published var isTabsOverviewPresented = false

    private let homeURL = URL(string: "https://www.google.com")!

    var selectedTab: BrowserTab? {
        tabs.first(where: { $0.id == selectedTabID })
    }

    init() {
        let initialTab = makeTab()
        tabs = [initialTab]
        selectedTabID = initialTab.id
        searchText = initialTab.addressText
    }

    func addTab() {
        let tab = makeTab(isPrivateMode: false)
        tabs.append(tab)
        selectTab(tab.id)
    }

    func addPrivateTab() {
        let tab = makeTab(isPrivateMode: true)
        tabs.append(tab)
        selectTab(tab.id)
    }

    func closeTab(_ id: BrowserTab.ID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else {
            return
        }

        let wasSelected = tabs[index].id == selectedTabID
        tabs.remove(at: index)

        if tabs.isEmpty {
            let newTab = makeTab()
            tabs = [newTab]
            selectedTabID = newTab.id
            searchText = newTab.addressText
            return
        }

        if wasSelected {
            let fallbackIndex = min(index, tabs.count - 1)
            let fallbackTab = tabs[fallbackIndex]
            selectedTabID = fallbackTab.id
            searchText = fallbackTab.addressText
        }
    }

    func selectTab(_ id: BrowserTab.ID) {
        selectedTabID = id
        searchText = selectedTab?.addressText ?? ""
    }

    func submitSearch() {
        guard let selectedTab,
            let destinationURL = resolvedURL(from: searchText)
        else {
            return
        }

        selectedTab.load(destinationURL)
    }

    func goBack() {
        selectedTab?.webView.goBack()
    }

    func goForward() {
        selectedTab?.webView.goForward()
    }

    func reload() {
        selectedTab?.webView.reload()
    }

    func openHomePage() {
        selectedTab?.showStartPage()
        searchText = ""
    }

    func togglePrivateModeForSelectedTab() {
        guard let selectedTab,
            let index = tabs.firstIndex(where: { $0.id == selectedTab.id })
        else {
            return
        }

        let replacementTab = makeTab(isPrivateMode: !selectedTab.isPrivateMode)

        if selectedTab.isShowingStartPage {
            replacementTab.showStartPage()
        } else if let url = selectedTab.currentURL {
            replacementTab.load(url)
        }

        tabs[index] = replacementTab
        selectedTabID = replacementTab.id
        searchText =
            replacementTab.isShowingStartPage ? "" : replacementTab.addressText
    }

    func showHistory() {
        isHistoryPresented = true
    }

    func showTabsOverview() {
        isTabsOverviewPresented = true
    }

    func hideTabsOverview() {
        isTabsOverviewPresented = false
    }

    func selectTabFromOverview(_ id: BrowserTab.ID) {
        selectTab(id)
        hideTabsOverview()
    }

    func addTabFromOverview() {
        addTab()
        hideTabsOverview()
    }

    func addPrivateTabFromOverview() {
        addPrivateTab()
        hideTabsOverview()
    }

    func openHistoryEntry(_ entry: BrowserHistoryEntry) {
        searchText = entry.url.absoluteString
        submitSearch()
    }

    func clearHistory() {
        history.removeAll()
    }

    private func makeTab(isPrivateMode: Bool = false) -> BrowserTab {
        let tab = BrowserTab(isPrivateMode: isPrivateMode)

        tab.stateDidChange = { [weak self] tab in
            guard let self, self.selectedTabID == tab.id else { return }
            self.searchText = tab.isShowingStartPage ? "" : tab.addressText
        }

        tab.webView.navigationDelegate = nil

        return tab
    }

    func recordVisit(title: String, url: URL, isPrivate: Bool) {
        guard !isPrivate else {
            return
        }

        let entry = BrowserHistoryEntry(
            title: title,
            url: url,
            visitedAt: Date(),
            isPrivate: isPrivate
        )

        if history.first?.url == entry.url, history.first?.title == entry.title
        {
            return
        }

        history.insert(entry, at: 0)
    }

    private func resolvedURL(from input: String) -> URL? {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedInput.isEmpty else {
            return homeURL
        }

        if let explicitURL = URL(string: trimmedInput),
            explicitURL.scheme != nil
        {
            return explicitURL
        }

        if trimmedInput.contains(".") {
            return URL(string: "https://\(trimmedInput)")
        }

        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: trimmedInput)
        ]

        return components?.url
    }
}
