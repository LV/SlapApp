//
//  HomeView.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/6/25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to SlapApp!")
                .font(.title)
                .fontWeight(.bold)

            Text("👋")
                .font(.system(size: 100))

            // Debug: Display profile info
            if let profile = profileManager.profile {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Profile Debug Info:")
                        .font(.headline)
                    Text("ID: \(profile.id.uuidString)")
                        .font(.caption)
                    Text("Username: \(profile.username ?? "Not set")")
                    Text("Email: \(profile.email ?? "Not set")")
                    Text("Display Name: \(profile.displayName ?? "Not set")")
                    Text("Phone: \(profile.phoneNumber ?? "Not set")")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            } else if profileManager.isLoading {
                ProgressView("Loading profile...")
            } else {
                Text("No profile data")
                    .foregroundColor(.red)
            }

            Spacer()

            Button(action: {
                Task {
                    do {
                        try await Config.supabase.auth.signOut()
                        await MainActor.run {
                            isLoggedIn = false
                        }
                    } catch {
                        print("Sign out error: \(error)")
                    }
                }
            }) {
                Text("Logout")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .padding()
    }
}
