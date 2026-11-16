//
//  StarRatingView.swift
//  Mythic
//
//  Created by vapidinfinity (esi) on 16/1/2025.
//

// Copyright © 2023-2025 vapidinfinity

import Foundation
import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    @Binding var hoveringOverIndex: Int
    @State var isInteractive: Bool = true

    var body: some View {
        HStack {
            ForEach(1..<6) { index in
                // buttons (rather than tap gestures), so each star is reachable by keyboard
                Button {
                    if isInteractive {
                        withAnimation {
                            rating = index
                            hoveringOverIndex = index
                        }
                    }
                } label: {
                    Image(systemName: "star")
                        .symbolVariant(hoveringOverIndex >= index ? .fill : .none)
                        .shadow(color: .secondary, radius: hoveringOverIndex == index ? 10 : 0)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if isInteractive {
                        withAnimation {
                            hoveringOverIndex = hovering ? index : hoveringOverIndex
                        }
                    }
                }
            }
        }
        // expose the five stars to VoiceOver as a single adjustable rating
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) out of 5 stars")
        .accessibilityAdjustableAction { direction in
            guard isInteractive else { return }

            switch direction {
            case .increment:
                rating = min(rating + 1, 5)
            case .decrement:
                rating = max(rating - 1, 1)
            @unknown default:
                break
            }

            hoveringOverIndex = rating
        }
        .onAppear {
            withAnimation {
                hoveringOverIndex = rating
            }
        }
        .onHover { hovering in
            withAnimation {
                hoveringOverIndex = hovering ? hoveringOverIndex : rating
            }
        }
        .imageScale(.large)
    }
}

#Preview {
    StarRatingView(rating: .constant(0), hoveringOverIndex: .constant(0), isInteractive: true)
}
