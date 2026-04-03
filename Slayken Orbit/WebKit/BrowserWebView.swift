//
//  BrowserWebView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI
import WebKit

struct BrowserWebView: UIViewRepresentable {
    @ObservedObject var tab: BrowserTab
    let onVisitRecorded: (String, URL, Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(tab: tab, onVisitRecorded: onVisitRecorded)
    }

    func makeUIView(context: Context) -> WKWebView {
        context.coordinator.attach(to: tab.webView)
        return tab.webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.tab = tab
        context.coordinator.attach(to: webView)
    }
}

extension BrowserWebView {
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        @MainActor var tab: BrowserTab
        let onVisitRecorded: (String, URL, Bool) -> Void

        private weak var webView: WKWebView?
        private var titleObservation: NSKeyValueObservation?
        private var urlObservation: NSKeyValueObservation?
        private var loadingObservation: NSKeyValueObservation?
        private var backObservation: NSKeyValueObservation?
        private var forwardObservation: NSKeyValueObservation?
        private var progressObservation: NSKeyValueObservation?
        private var scrollObservation: NSKeyValueObservation?
        private var snapshotWorkItem: DispatchWorkItem?

        @MainActor
        init(
            tab: BrowserTab,
            onVisitRecorded: @escaping (String, URL, Bool) -> Void
        ) {
            self.tab = tab
            self.onVisitRecorded = onVisitRecorded
        }

        @MainActor
        func attach(to webView: WKWebView) {
            guard self.webView !== webView else {
                syncState(from: webView)
                return
            }

            self.webView = webView
            webView.navigationDelegate = self
            webView.uiDelegate = self
            observe(webView)
            syncState(from: webView)
        }

        private func observe(_ webView: WKWebView) {
            titleObservation = webView.observe(
                \.title,
                options: [.initial, .new]
            ) { [weak self] webView, _ in
                self?.syncState(from: webView)
            }

            urlObservation = webView.observe(\.url, options: [.initial, .new]) {
                [weak self] webView, _ in
                self?.syncState(from: webView)
            }

            loadingObservation = webView.observe(
                \.isLoading,
                options: [.initial, .new]
            ) { [weak self] webView, _ in
                self?.syncState(from: webView)
                self?.schedulePreviewCapture(from: webView, delay: 0.25)
            }

            backObservation = webView.observe(
                \.canGoBack,
                options: [.initial, .new]
            ) { [weak self] webView, _ in
                self?.syncState(from: webView)
            }

            forwardObservation = webView.observe(
                \.canGoForward,
                options: [.initial, .new]
            ) { [weak self] webView, _ in
                self?.syncState(from: webView)
            }

            progressObservation = webView.observe(
                \.estimatedProgress,
                options: [.new]
            ) { [weak self] webView, _ in
                self?.schedulePreviewCapture(from: webView, delay: 0.35)
            }

            scrollObservation = webView.scrollView.observe(
                \.contentOffset,
                options: [.new]
            ) { [weak self] _, _ in
                guard let self, let webView = self.webView else { return }
                self.schedulePreviewCapture(from: webView, delay: 0.4)
            }
        }

        private func syncState(from webView: WKWebView) {
            Task { @MainActor in
                tab.updateState(
                    title: webView.title,
                    url: webView.url ?? tab.currentURL,
                    isLoading: webView.isLoading,
                    canGoBack: webView.canGoBack,
                    canGoForward: webView.canGoForward
                )
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
        {
            syncState(from: webView)
            if let url = webView.url {
                let title = webView.title?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                onVisitRecorded(
                    title?.isEmpty == false ? title! : (url.host ?? "Seite"),
                    url,
                    tab.isPrivateMode
                )
            }
            schedulePreviewCapture(from: webView, delay: 0.1)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
        {
            syncState(from: webView)
            schedulePreviewCapture(from: webView, delay: 0.25)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            syncState(from: webView)
            schedulePreviewCapture(from: webView, delay: 0.1)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }

            return nil
        }

        private func schedulePreviewCapture(
            from webView: WKWebView,
            delay: TimeInterval
        ) {
            snapshotWorkItem?.cancel()

            let workItem = DispatchWorkItem { [weak self, weak webView] in
                guard let self, let webView else { return }
                self.capturePreview(from: webView)
            }

            snapshotWorkItem = workItem
            DispatchQueue.main.asyncAfter(
                deadline: .now() + delay,
                execute: workItem
            )
        }

        private func capturePreview(from webView: WKWebView) {
            guard !tab.isShowingStartPage else {
                return
            }

            guard !tab.isPrivateMode else {
                tab.updatePreview(nil)
                return
            }

            guard webView.bounds.width > 1, webView.bounds.height > 1 else {
                return
            }

            let configuration = WKSnapshotConfiguration()
            configuration.afterScreenUpdates = true
            configuration.rect = webView.bounds
            configuration.snapshotWidth = NSNumber(
                value: min(webView.bounds.width, 540)
            )

            webView.takeSnapshot(with: configuration) { [weak self] image, _ in
                Task { @MainActor in
                    self?.tab.updatePreview(image)
                }
            }
        }
    }
}
