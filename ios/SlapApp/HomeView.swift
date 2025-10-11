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
        NavigationView {
            VStack(spacing: 30) {
                Text("Welcome to SlapApp!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("👋")
                    .font(.system(size: 100))

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView().environmentObject(profileManager)) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .task {
                // Fetch profile if not already loaded
                if profileManager.profile == nil {
                    await profileManager.fetchProfile()
                }
            }
        }
    }
}
