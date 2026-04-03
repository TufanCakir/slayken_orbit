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
    @Published private(set) var savedPages: [SavedPage] = []
    @Published var isHistoryPresented = false
    @Published var isTabsOverviewPresented = false
    @Published var isAddPagePresented = false
    @Published var isSavedPagesPresented = false

    private let homeURL = URL(string: "https://www.google.com")!
    private let savedPagesKey = "saved_pages"
    private let userDefaults: UserDefaults

    var selectedTab: BrowserTab? {
        tabs.first(where: { $0.id == selectedTabID })
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadSavedPages()

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
        guard let selectedTab else {
            return
        }

        if selectedTab.canGoBack {
            selectedTab.webView.goBack()
        } else if !selectedTab.isShowingStartPage {
            openHomePage()
        }
    }

    func goForward() {
        guard let selectedTab else {
            return
        }

        if selectedTab.canGoForward {
            selectedTab.webView.goForward()
        } else if selectedTab.isShowingStartPage,
            let lastContentURL = selectedTab.lastContentURL
        {
            selectedTab.load(lastContentURL)
        }
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

    func showAddPage() {
        isAddPagePresented = true
    }

    func hideAddPage() {
        isAddPagePresented = false
    }

    func showSavedPages() {
        isSavedPagesPresented = true
    }

    func hideSavedPages() {
        isSavedPagesPresented = false
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

    func addPageFromLink(
        _ input: String,
        opensInNewTab: Bool,
        shouldSave: Bool
    ) {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let destinationURL = resolvedURL(from: trimmedInput) else {
            return
        }

        if shouldSave {
            savePage(
                SavedPage(
                    title: destinationURL.host ?? trimmedInput,
                    kind: .link,
                    link: destinationURL.absoluteString
                )
            )
        }

        let tab = targetTab(opensInNewTab: opensInNewTab)
        tab.load(destinationURL)
        selectTab(tab.id)
        hideAddPage()
    }

    func addPageFromHTML(
        title: String,
        html: String,
        opensInNewTab: Bool,
        shouldSave: Bool
    ) {
        let trimmedHTML = html.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHTML.isEmpty else {
            return
        }

        let tab = targetTab(opensInNewTab: opensInNewTab)
        let resolvedTitle =
            title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Eigene HTML-Seite"
            : title.trimmingCharacters(in: .whitespacesAndNewlines)

        if shouldSave {
            savePage(
                SavedPage(
                    title: resolvedTitle,
                    kind: .html,
                    html: trimmedHTML
                )
            )
        }

        tab.loadHTML(trimmedHTML, title: resolvedTitle)
        selectTab(tab.id)
        hideAddPage()
    }

    func openSavedPage(_ page: SavedPage) {
        let tab = targetTab(opensInNewTab: true)

        switch page.kind {
        case .link:
            guard let link = page.link, let url = URL(string: link) else {
                return
            }
            tab.load(url)
        case .html:
            guard let html = page.html else {
                return
            }
            tab.loadHTML(html, title: page.title)
        }

        selectTab(tab.id)
        hideSavedPages()
    }

    func deleteSavedPage(_ id: SavedPage.ID) {
        savedPages.removeAll { $0.id == id }
        persistSavedPages()
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

    private func savePage(_ page: SavedPage) {
        savedPages.insert(page, at: 0)
        persistSavedPages()
    }

    private func loadSavedPages() {
        guard
            let data = userDefaults.data(forKey: savedPagesKey),
            let decodedPages = try? JSONDecoder().decode([SavedPage].self, from: data)
        else {
            savedPages = []
            return
        }

        savedPages = decodedPages
    }

    private func persistSavedPages() {
        guard let data = try? JSONEncoder().encode(savedPages) else {
            return
        }

        userDefaults.set(data, forKey: savedPagesKey)
    }

    private func targetTab(opensInNewTab: Bool) -> BrowserTab {
        if opensInNewTab || selectedTab == nil {
            let tab = makeTab(
                isPrivateMode: selectedTab?.isPrivateMode ?? false
            )
            tabs.append(tab)
            return tab
        }

        return selectedTab!
    }

    func recordVisit(title: String, url: URL, isPrivate: Bool) {
        guard !isPrivate, url.scheme != "about" else {
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
