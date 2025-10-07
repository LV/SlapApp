//
//  ContentView.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/6/25.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 20) {
                Text("👋")
                    .font(.system(size: 100))

                Text("SlapApp")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    handleSignInWithApple(result)
                }
            )
            .frame(height: 50)
            .padding(.horizontal, 40)
            .signInWithAppleButtonStyle(.white)

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.6), Color.red.opacity(0.75)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }

    func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email

                // TODO: Send to Supabase for authentication
                print("User ID: \(userIdentifier)")
                print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
                print("Email: \(email ?? "N/A")")

                // Just login for now
                isLoggedIn = true
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
}

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
                isLoggedIn = false
            }) {
                Text("Logout")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
