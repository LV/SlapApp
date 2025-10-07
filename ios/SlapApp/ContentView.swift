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
    @State private var errorMessage: String?

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
        .overlay(alignment: .top) {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
                    .padding(.top, 60)
            }
        }
    }

    func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let identityToken = appleIDCredential.identityToken,
                      let tokenString = String(data: identityToken, encoding: .utf8) else {
                    errorMessage = "Failed to get identity token"
                    return
                }

                Task {
                    do {
                        // Sign in with Supabase using Apple ID token
                        let session = try await Config.supabase.auth.signInWithIdToken(
                            credentials: .init(
                                provider: .apple,
                                idToken: tokenString
                            )
                        )

                        print("Successfully signed in! User ID: \(session.user.id)")

                        // Update login state on main thread
                        await MainActor.run {
                            isLoggedIn = true
                        }
                    } catch {
                        print("Supabase auth error: \(error)")
                        await MainActor.run {
                            errorMessage = "Authentication failed: \(error.localizedDescription)"
                        }
                    }
                }
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
            errorMessage = "Sign in failed: \(error.localizedDescription)"
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

#Preview {
    ContentView()
}
