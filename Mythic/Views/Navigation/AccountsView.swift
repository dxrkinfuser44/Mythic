//
//  AccountsView.swift
//  Mythic
//
//  Created by vapidinfinity (esi) on 12/3/2024.
//

// Copyright © 2023-2025 vapidinfinity

import SwiftUI
import SwordRPC

struct AccountsView: View {
    @ObservedObject private var epicWebAuthViewModel: EpicWebAuthViewModel = .shared

    @State private var isEpicSignOutConfirmationAlertPresented: Bool = false
    @State private var epicSignOutError: Error?
    @State private var isEpicSignOutErrorAlertPresented: Bool = false
    @State private var isEpicAccountCardRefreshed = false
    @State private var steamSignedInUser = SteamAuth.currentSteamID
    @State private var isSteamSignOutConfirmationAlertPresented = false
    @State private var isSteamAuthPresented = false
    @State private var steamAccountError: Error?
    @State private var isSteamAccountErrorAlertPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                AccountCard(
                    signedInUser: .constant(try? Legendary.retrieveUser()),
                    image: Image("EGFaceless"),
                    storefront: .epicGames,
                    signInAction: {
                        Task { @MainActor in
                            epicWebAuthViewModel.showSignInWindow()
                        }
                    },
                    signOutAction: {
                        isEpicSignOutConfirmationAlertPresented = true
                    }
                )
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quinary)
                )
                .alert(
                    "Are you sure you want to sign out of Epic Games?",
                    isPresented: $isEpicSignOutConfirmationAlertPresented
                ) {
                    Button(role: .destructive) {
                        Task {
                            do {
                                try await Legendary.signOut()
                                isEpicAccountCardRefreshed.toggle()
                            } catch {
                                epicSignOutError = error
                                isEpicSignOutErrorAlertPresented = true
                            }
                        }
                    } label: {
                        Text("Sign Out")
                    }

                    Button(String(localized: "Cancel"), role: .cancel) { }
                }
                .id(isEpicAccountCardRefreshed)

                AccountCard(
                    signedInUser: $steamSignedInUser,
                    image: Image("Steam"),
                    storefront: .steam,
                    signInAction: {
                        isSteamAuthPresented = true
                    },
                    signOutAction: {
                        isSteamSignOutConfirmationAlertPresented = true
                    }
                )
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quinary)
                )
                .sheet(isPresented: $isSteamAuthPresented) {
                    SteamWebAuthView(isPresented: $isSteamAuthPresented) { steamID in
                        steamSignedInUser = steamID
                        Task { @MainActor in
                            if let summary = try? await SteamWebAPI.getPlayerSummary(steamID: steamID) {
                                steamSignedInUser = SteamClient.sanitizedTitle(summary.personaname) ?? steamID
                            }
                            do {
                                try await GameDataStore.shared.refreshFromStorefronts(.steam)
                            } catch {
                                steamAccountError = error
                                isSteamAccountErrorAlertPresented = true
                            }
                        }
                    }
                    .frame(minWidth: 650, minHeight: 450)
                }
                .alert(
                    String(localized: "Are you sure you want to sign out of Steam?"),
                    isPresented: $isSteamSignOutConfirmationAlertPresented
                ) {
                    Button(role: .destructive) {
                        SteamAuth.signOut()
                        steamSignedInUser = nil
                        Task { @MainActor in
                            try? await GameDataStore.shared.refreshFromStorefronts(.steam)
                        }
                    } label: {
                        Text("Sign Out")
                    }

                    Button(String(localized: "Cancel"), role: .cancel) { }
                }
                .task {
                    guard let steamID = SteamAuth.currentSteamID else {
                        steamSignedInUser = nil
                        return
                    }
                    steamSignedInUser = steamID
                    if let summary = try? await SteamWebAPI.getPlayerSummary(steamID: steamID) {
                        steamSignedInUser = SteamClient.sanitizedTitle(summary.personaname) ?? steamID
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .alert(
                "Unable to sign out of Epic Games.",
                isPresented: $isEpicSignOutErrorAlertPresented,
                presenting: epicSignOutError
            ) { _ in
                Button(String(localized: "OK"), role: .cancel) { }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
        .alert(
            String(localized: "Unable to refresh your Steam account."),
            isPresented: $isSteamAccountErrorAlertPresented,
            presenting: steamAccountError
        ) { _ in
            Button(String(localized: "OK"), role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
        .navigationTitle("Accounts")
        .task(priority: .background) {
            discordRPC.setPresence({
                var presence: RichPresence = .init()
                presence.details = "Currently in the accounts section."
                presence.state = "Checking out all their accounts"
                presence.timestamps.start = .now
                presence.assets.largeImage = "macos_512x512_2x"

                return presence
            }())
        }
    }
}

extension AccountsView {
    struct AccountCard: View {
        @Binding var signedInUser: String?

        var image: Image
        var storefront: Game.Storefront
        var signInAction: () -> Void
        var signOutAction: () -> Void

        var body: some View {
            HStack(spacing: 12) {
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 60)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text(storefront.description)
                        .font(.title.bold())

                    Text(signedInUser != nil ? "Signed in as \"\(signedInUser ?? "Unknown")\"" : "Not signed in")
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                // the confirmation alerts are presented by AccountsView.
                if signedInUser != nil {
                    Button("Sign Out", systemImage: "person.slash", role: .destructive, action: signOutAction)
                } else {
                    Button("Sign In", systemImage: "person", action: signInAction)
                }
            }
            .accessibilityElement(children: .contain)
        }
    }
}

#Preview {
    AccountsView()
}
