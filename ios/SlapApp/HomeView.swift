//
//  HomeView.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/6/25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to SlapApp!")
                .font(.title)
                .fontWeight(.bold)

            Text("👋")
                .font(.system(size: 100))

            Text("Home screen with slap button coming next...")
                .foregroundColor(.gray)

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
