//
//  ContentView.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/6/25.
//

import SwiftUI

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
    @State private var isLoginMode = true
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 0) {
            // Top section - Icon and Title
            VStack(spacing: 20) {
                Spacer()

                Text("👋")
                    .font(.system(size: 100))

                Text("SlapApp")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.orange)

                Spacer()
            }

            // Bottom section - Form
            VStack(spacing: 20) {
                Picker("Mode", selection: $isLoginMode) {
                    Text("Login").tag(true)
                    Text("Register").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)

                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    if isLoginMode {
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        TextField("Phone Number", text: $phoneNumber)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.phonePad)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal, 40)

                Button(action: handleSubmit) {
                    Text(isLoginMode ? "Login" : "Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)

                Spacer()
            }
        }
        .padding()
    }

    func handleSubmit() {
        // Allow login without validation for now
        // TODO: Replace with Supabase auth
        isLoggedIn = true
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
