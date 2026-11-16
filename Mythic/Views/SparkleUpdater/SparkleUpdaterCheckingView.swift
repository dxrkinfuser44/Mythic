//
//  SparkleUpdaterCheckingView.swift
//  Mythic
//
//  Created by Josh on 10/23/24.
//

// Copyright © 2023-2025 vapidinfinity

import SwiftUI

extension SparkleUpdater {
    struct CheckingView: View {
        let cancel: () -> Void

        var body: some View {
            RichAlertView(
                title: {
                    Text("Checking for Updates")
                },
                content: {
                    ProgressView()
                        .progressViewStyle(.linear)
                },
                buttonsRight: {
                    Button("Cancel") {
                        cancel()
                    }
                    .keyboardShortcut(.cancelAction)
                }
            )
        }
    }
}

#Preview {
    SparkleUpdater.CheckingView(cancel: {})
}
