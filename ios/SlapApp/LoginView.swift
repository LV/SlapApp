//
//  LoginView.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/6/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @EnvironmentObject var profileManager: ProfileManager
    @State private var errorMessage: String?
    @State private var gradientAngle: Double = 0
    @State private var waveRotation: Double = 0
    @State private var soundTimer: Timer?

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 20) {
                Text("👋")
                    .font(.system(size: 100))
                    .rotationEffect(.degrees(waveRotation))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            waveRotation = 15
                        }
                    }

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
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.6), Color.red.opacity(0.75)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.4), Color.red.opacity(0.6)]),
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .opacity(gradientAngle)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    gradientAngle = 1
                }
            }
        )
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            if let errorMessage = errorMessage {
                HStack(spacing: 12) {
                    Text("⚠️")
                        .font(.title2)

                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: errorMessage)
        .onAppear {
            startRandomSounds()
        }
        .onDisappear {
            stopRandomSounds()
        }
    }

    func startRandomSounds() {
        // Play a sound at random intervals between 2-6 seconds
        soundTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...6), repeats: false) { _ in
            SoundManager.shared.playRandomSound()
            // Schedule the next sound
            startRandomSounds()
        }
    }

    func stopRandomSounds() {
        soundTimer?.invalidate()
        soundTimer = nil
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

                        // Fetch user profile
                        await profileManager.fetchProfile()

                        // Update login state on main thread
                        await MainActor.run {
                            isLoggedIn = true
                        }
                    } catch {
                        print("Supabase auth error: \(error)")
                        await MainActor.run {
                            errorMessage = "Authentication failed: \(error.localizedDescription)"
                        }

                        // Clear error after 3 seconds
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        await MainActor.run {
                            errorMessage = nil
                        }
                    }
                }
            }
        case .failure(let error):
            // Don't show error if user canceled the sign-in
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }

            print("Sign in with Apple failed: \(error.localizedDescription)")
            errorMessage = "Sign in failed: \(error.localizedDescription)"

            // Clear error after 3 seconds
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    errorMessage = nil
                }
            }
        }
    }
}
