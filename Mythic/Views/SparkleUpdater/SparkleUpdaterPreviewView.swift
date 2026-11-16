//
//  SparkleUpdaterPreviewView.swift
//  Mythic
//
//  Created by Josh on 10/23/24.
//

// Copyright © 2023-2025 vapidinfinity

import SwiftUI
import Sparkle
import MarkdownUI
import ColorfulX

extension SparkleUpdater {
    struct PreviewView: View {
        let appcast: SUAppcastItem
        let choice: (SparkleUpdateController.UpdateChoice) -> Void

        @State private var colorfulViewColors: [Color] = [
            .init(hex: "#7541FF"),
            .init(hex: "#5412FF"),
            .init(hex: "#1B1233") // dark, so the white text keeps its contrast in light mode too
        ]
        @State private var colorfulAnimationSpeed: Double = 1
        @State private var colorfulAnimationNoise: Double = 0

        var body: some View {
            HStack(spacing: 0) {
                VStack(alignment: .center) {
                    VStack {
                        VStack {
                            BundleIconView()
                                .shadow(radius: .leastNormalMagnitude)
                                .aspectRatio(contentMode: .fit)
                            
                            VStack {
                                Text(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown")
                                    .font(.title2)
                                    .bold()
                                
                                Text("v\(appcast.displayVersionString.isEmpty ? "0.0.0" : appcast.displayVersionString) (\(appcast.versionString.isEmpty ? "0" : appcast.versionString))")
                                    .font(.caption)
                            }
                        }
                        
                        Text("You are running \(Mythic.appVersion?.description ?? "Unknown"). Would you like to download the update?")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }

                    VStack {
                        Button {
                            choice(.update)
                        } label: {
                            Text("Update")
                                .padding(.vertical)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(.capsule)
                        .keyboardShortcut(.defaultAction)
                        
                        if !appcast.isCriticalUpdate {
                            Button {
                                choice(.dismiss)
                            } label: {
                                Text("Dismiss")
                                    .padding(.vertical)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .clipShape(.capsule)
                            .keyboardShortcut(.cancelAction)
                        }
                    }
                }
                .padding()
                .frame(maxHeight: .infinity)
                .background(
                    ColorfulView(color: $colorfulViewColors,
                                 speed: $colorfulAnimationSpeed,
                                 noise: $colorfulAnimationNoise)
                )
                .foregroundStyle(.white)
                .environment(\.colorScheme, .dark) // controls sit on the dark gradient
                
                if let itemDescription = appcast.itemDescription, !itemDescription.isEmpty {
                    ScrollView {
                        Markdown {
                            itemDescription
                        }
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ContentUnavailableView(
                        "No Release Notes Found.",
                        systemImage: "pc"
                    )
                }
            }
            .fixedSize()
        }
    }
}

#Preview {
    SparkleUpdater.PreviewView(appcast: .empty(), choice: { _ in })
}
