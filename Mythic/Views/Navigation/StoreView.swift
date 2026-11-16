//
//  StoreView.swift
//  Mythic
//
//  Created by vapidinfinity (esi) on 10/9/2023.
//

// Copyright © 2023-2025 vapidinfinity

import SwiftUI
import SwordRPC
import WebKit

struct StoreView: View {
    @State private var navigator = WebViewNavigator()
    @State private var url: URL = .init(string: "https://store.epicgames.com/")!

    @CodableAppStorage("epicGamesWebDataStore") var epicGamesWebDataStore: UUID = .init()

    var body: some View {
        WebView(
            url: url,
            datastore: .init(forIdentifier: epicGamesWebDataStore),
            error: .constant(nil),
            navigator: navigator
        )
        .overlay(alignment: .top) {
            if navigator.isLoading {
                ProgressView()
                    .progressViewStyle(.linear)
                    .accessibilityLabel(Text("Loading page"))
            }
        }

        .navigationTitle("Store")

        .task(priority: .background) {
            discordRPC.setPresence({
                var presence: RichPresence = .init()
                presence.details = "Currently browsing \(url)"
                presence.state = "Looking for games to purchase"
                presence.timestamps.start = .now
                presence.assets.largeImage = "macos_512x512_2x"

                return presence
            }())
        }

        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    navigator.goBack()
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                }
                .disabled(!navigator.canGoBack)
                .help("Go back")

                Button {
                    navigator.goForward()
                } label: {
                    Label("Forward", systemImage: "chevron.forward")
                }
                .disabled(!navigator.canGoForward)
                .help("Go forward")
            }

            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    navigator.reload()
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
                .help("Reload this page")

                Button {
                    NSWorkspace.shared.open(navigator.currentURL ?? url)
                } label: {
                    Label("Open in Browser", systemImage: "arrow.up.forward")
                }
                .help("Open this page in your browser")
            }
        }
    }
}

#Preview {
    StoreView()
}
