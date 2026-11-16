//
//  WebView.swift
//  Mythic
//
// Copyright © 2023-2025 vapidinfinity

import SwiftUI
import WebKit
import OSLog

/// Holds the navigation state of a ``WebView`` so toolbars can drive it.
@Observable @MainActor
final class WebViewNavigator {
    private(set) var canGoBack = false
    private(set) var canGoForward = false
    private(set) var isLoading = false
    private(set) var currentURL: URL?

    @ObservationIgnored private weak var webView: WKWebView?
    @ObservationIgnored private var observations: [NSKeyValueObservation] = []

    func attach(to webView: WKWebView) {
        observations.forEach { $0.invalidate() }
        self.webView = webView

        observations = [
            webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in self?.refresh() }
            },
            webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in self?.refresh() }
            },
            webView.observe(\.isLoading, options: [.initial, .new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in self?.refresh() }
            },
            webView.observe(\.url, options: [.initial, .new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in self?.refresh() }
            }
        ]
    }

    func goBack() {
        _ = webView?.goBack()
    }

    func goForward() {
        _ = webView?.goForward()
    }

    func reload() {
        _ = webView?.reload()
    }

    /// Re-reads state from the web view; KVO only signals that something changed.
    private func refresh() {
        guard let webView else { return }

        if canGoBack != webView.canGoBack { canGoBack = webView.canGoBack }
        if canGoForward != webView.canGoForward { canGoForward = webView.canGoForward }
        if isLoading != webView.isLoading { isLoading = webView.isLoading }
        if currentURL != webView.url { currentURL = webView.url }
    }
}

struct WebView: NSViewRepresentable {
    var url: URL
    var datastore: WKWebsiteDataStore = .default()

    @Binding var error: Error?
    var navigator: WebViewNavigator?

    let log = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "WebView"
    )

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = datastore

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        navigator?.attach(to: webView)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Compare against the last URL this view asked for, not the page the user
        // has since browsed to; otherwise every re-render reloads the start page.
        guard context.coordinator.lastRequestedURL != url else { return }
        context.coordinator.lastRequestedURL = url

        let request = URLRequest(url: url)
        nsView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var lastRequestedURL: URL?

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
            parent.log.error("\(error.localizedDescription)")
            parent.error = error
        }
    }
}

#Preview {
    WebView(url: .init(string: "https://example.com")!, error: .constant(nil))
}
