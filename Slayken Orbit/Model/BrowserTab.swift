//
//  BrowserTab.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import Combine
import CryptoKit
import SwiftUI
import UIKit
import WebKit

@MainActor
final class BrowserTab: ObservableObject, Identifiable {
    let id = UUID()
    let webView: WKWebView

    @Published var title: String
    @Published var addressText: String
    @Published var previewImage: UIImage?
    @Published var currentURL: URL?
    @Published var isLoading = false
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isShowingStartPage: Bool
    @Published var isPrivateMode: Bool

    var stateDidChange: ((BrowserTab) -> Void)?

    init(initialURL: URL? = nil, isPrivateMode: Bool = false) {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        if isPrivateMode {
            configuration.websiteDataStore = .nonPersistent()
        }

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true

        title = "Start"
        addressText = ""
        currentURL = nil
        isShowingStartPage = initialURL == nil
        self.isPrivateMode = isPrivateMode

        if let initialURL {
            load(initialURL)
        }
    }

    func load(_ url: URL) {
        isShowingStartPage = false
        addressText = url.absoluteString
        currentURL = url
        previewImage = BrowserPreviewStore.shared.loadPreview(
            for: url,
            isPrivate: isPrivateMode
        )
        webView.load(URLRequest(url: url))
        stateDidChange?(self)
    }

    func showStartPage() {
        webView.stopLoading()
        title = "Start"
        addressText = ""
        currentURL = nil
        previewImage = nil
        isLoading = false
        canGoBack = false
        canGoForward = false
        isShowingStartPage = true
        stateDidChange?(self)
    }

    func updateState(
        title: String?,
        url: URL?,
        isLoading: Bool,
        canGoBack: Bool,
        canGoForward: Bool
    ) {
        guard !isShowingStartPage else {
            stateDidChange?(self)
            return
        }

        let trimmedTitle = title?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if let trimmedTitle, !trimmedTitle.isEmpty {
            self.title = trimmedTitle
        } else if let host = url?.host, !host.isEmpty {
            self.title = host
        } else {
            self.title = "Neuer Tab"
        }

        if let url {
            if currentURL != url {
                previewImage = BrowserPreviewStore.shared.loadPreview(
                    for: url,
                    isPrivate: isPrivateMode
                )
            }
            addressText = url.absoluteString
        }

        currentURL = url
        self.isLoading = isLoading
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        isShowingStartPage = false
        stateDidChange?(self)
    }

    func updatePreview(_ image: UIImage?) {
        previewImage = image
        BrowserPreviewStore.shared.savePreview(
            image,
            for: currentURL,
            isPrivate: isPrivateMode
        )
        stateDidChange?(self)
    }
}

@MainActor
private final class BrowserPreviewStore {
    static let shared = BrowserPreviewStore()

    private let fileManager = FileManager.default
    private let directoryURL: URL

    private init() {
        directoryURL = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent("BrowserPreviews", isDirectory: true)
        try? fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }

    func loadPreview(for url: URL, isPrivate: Bool) -> UIImage? {
        guard !isPrivate else {
            return nil
        }

        let fileURL = previewFileURL(for: url)
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    func savePreview(_ image: UIImage?, for url: URL?, isPrivate: Bool) {
        guard !isPrivate, let url else {
            return
        }

        let fileURL = previewFileURL(for: url)

        guard let image, let data = image.jpegData(compressionQuality: 0.72)
        else {
            try? fileManager.removeItem(at: fileURL)
            return
        }

        try? data.write(to: fileURL, options: .atomic)
    }

    private func previewFileURL(for url: URL) -> URL {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let fileName = digest.compactMap { String(format: "%02x", $0) }.joined()
        return directoryURL.appendingPathComponent("\(fileName).jpg")
    }
}
