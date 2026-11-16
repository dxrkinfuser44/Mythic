//
//  SupportView.swift
//  Mythic
//
//  Created by vapidinfinity (esi) on 12/9/2023.
//

// Copyright © 2023-2025 vapidinfinity

import SwiftUI
import AppKit
import SwordRPC

struct SupportView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Support")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)

            Form {
                Section("Resources") {
                    Link(destination: URL(string: "https://docs.getmythic.app/")!) {
                        Label("Documentation", systemImage: "book")
                    }

                    Link(destination: URL(string: "https://getmythic.app/faq/")!) {
                        Label("FAQ", systemImage: "questionmark.circle")
                    }

                    Link(destination: URL(string: "https://docs.google.com/spreadsheets/d/1W_1UexC1VOcbP2CHhoZBR5-8koH-ZPxJBDWntwH-tsc/")!) {
                        Label("Compatibility List", systemImage: "list.bullet")
                    }
                }

                Section {
                    Link(destination: URL(string: "https://github.com/MythicApp/Mythic/issues")!) {
                        Label("Report an issue", systemImage: "exclamationmark.bubble")
                    }

                    Link(destination: URL(string: "https://discord.gg/kQKdvjTVqh")!) {
                        Label("Create a support ticket", systemImage: "bubble.left.and.bubble.right")
                    }
                } header: {
                    Text("Receive Help")
                } footer: {
                    Text("Please consult resources before creating an issue — you may find a solution there.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
            // keep the window's own material visible behind the form
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task(priority: .background) {
            // Set rich presence using SwordRPC
            discordRPC.setPresence({
                var presence = RichPresence()
                presence.details = "Looking for help"
                presence.state = "Viewing Support"
                presence.timestamps.start = .now
                presence.assets.largeImage = "macos_512x512_2x"
                return presence
            }())
        }
        .navigationTitle("Support")
    }
}

public class SupportWindowController: NSWindowController {
    static var shared: SupportWindowController?

    convenience init() {
        let supportView = SupportView()
        let hosting = NSHostingController(rootView: supportView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
            styleMask: [
                .titled,
                .closable,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )

        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.titleVisibility = .hidden

        if let zoomButton = window.standardWindowButton(.zoomButton) {
            zoomButton.isEnabled = false
        }

        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .sidebar
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 28),
            hosting.view.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
        ])

        window.contentView = visualEffectView
        window.center()
        self.init(window: window)
    }

    static func show() {
        if let existing = shared {
            existing.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            let controller = SupportWindowController()
            shared = controller
            controller.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

#Preview {
    SupportView()
}
