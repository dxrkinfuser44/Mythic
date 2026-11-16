//
//  AboutView.swift
//  Mythic
//
//  Created by vapidinfinity (esi) on 25/4/2025.
//

// Copyright © 2023-2025 vapidinfinity

import Foundation
import SwiftUI
import SemanticVersion
import ColorfulX

struct AboutView: View {
    @State private var colorfulAnimationColors: [Color] = [
        .init(hex: "#5412F6"),
        .init(hex: "#7E1ED8"),
        .init(hex: "#2C2C2C")
    ]
    @State private var colorfulAnimationSpeed: Double = 1
    @State private var colorfulAnimationNoise: Double = 0
    
    @State private var showGradientView: Bool = false
    @State private var isChevronHovered: Bool = false

    @State private var engineVersion: SemanticVersion?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack(alignment: .center) {
                        BundleIconView()
                            .frame(width: 100, height: 100)
                        
                        // the name and versions stay visible, whether or not the pointer is over the window.
                        Text("Mythic")
                            .font(.largeTitle)
                        Text("© by vapidinfinity ✦")

                        Divider()
                            .frame(width: 100)

                        VStack {
                            if let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                               let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
                               let mythicVersion: SemanticVersion = .init("\(shortVersion)+\(bundleVersion)") {
                                Text(mythicVersion.prettyString)
                            }

                            if let engineVersion {
                                Text("Engine \(engineVersion.prettyString)")
                            }
                        }
                        .task { @MainActor in
                            engineVersion = await Engine.installedVersion
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        // versions are often copied into bug reports
                        .textSelection(.enabled)
                    }
                    .id(1)
                    .frame(height: 400)
                    .overlay(alignment: .bottom) {
                        Button {
                            withAnimation(reduceMotion ? nil : .easeInOut) {
                                proxy.scrollTo(2)
                            }
                        } label: {
                            VStack {
                                if isChevronHovered {
                                    Text("scroll... or just jump down!")
                                        .frame(width: 500)
                                }
                                
                                Image(systemName: "chevron.down")
                            }
                        }
                        .buttonStyle(.plain)
                        .symbolEffect(.pulse, isActive: !reduceMotion)
                        .onHover { hovered in
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.4)) {
                                isChevronHovered = hovered
                            }
                        }
                        .padding()
                        .accessibilityLabel("Scroll to acknowledgements")
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    Text(#""An open-source macOS game launcher with the ability to play Windows games through a custom implementation of Apple's Game Porting Toolkit — supporting multiple platforms.""#)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(alignment: .center, spacing: 10) {
                        Text("Acknowledgements")
                            .font(.title)
                        
                        AcknowledgementCard(
                            URL: .init(string: "https://codeweavers.com/")!,
                            image: Image("CrossOver"),
                            title: "⭐ CodeWeavers, and Gcenx",
                            description: "Developing, maintaining, and porting Wine, the technology behind Mythic's underlying Windows® → macOS API translation layer."
                        )
                        
                        AcknowledgementCard(
                            URL: .init(string: "https://getwhisky.app/")!,
                            image: Image("Whisky"),
                            title: "🕊️ Whisky",
                            description: "Providing Mythic Engine's foundation."
                        )
                        
                        AcknowledgementCard(
                            URL: .init(string: "https://github.com/MythicApp/Mythic#dependencies")!,
                            image: Image("BlankAppIcon"),
                            title: "⭐ Others",
                            description: "View Mythic's other dependencies."
                        )
                    }
                    .id(2)
                    .padding()
                    .frame(height: 400)
                }
            }
            .background(showGradientView ? nil : WindowBlurView().ignoresSafeArea())
            // with Reduce Motion, the gradient is drawn but doesn't move.
            .background(showGradientView ? ColorfulView(color: $colorfulAnimationColors, speed: .constant(reduceMotion ? 0 : colorfulAnimationSpeed), noise: $colorfulAnimationNoise).ignoresSafeArea() : nil)
            // the gradient is dark in either appearance, so text atop it must be light.
            .environment(\.colorScheme, showGradientView ? .dark : colorScheme)
            .frame(width: 285, height: 400)
            .onHover { hovering in
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 1)) {
                    showGradientView = hovering
                }
            }
            .fixedSize()
        }
    }
}

extension AboutView {
    struct AcknowledgementCard: View {
        var URL: URL
        var image: Image
        var title: String
        var description: String
        
        @State private var isChevronHovering: Bool = false
        
        var body: some View {
            Button {
                NSWorkspace.shared.open(URL)
            } label: {
                HStack(alignment: .center) {
                    image
                        .resizable()
                        .frame(width: 48, height: 48)
                        .aspectRatio(contentMode: .fit)
                    
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.headline)
                        
                        Text(description)
                            .tint(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .onHover {
                            isChevronHovering = $0
                        }
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom)
        }
    }
}

#Preview {
    AboutView()
}
