//
//  ProfileView.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/11/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.6), Color.red.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(profileInitials)
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .padding(.top, 20)

                    // Profile Details
                    VStack(spacing: 16) {
                        if let profile = profileManager.profile {
                            ProfileDetailRow(
                                icon: "person.fill",
                                label: "Display Name",
                                value: profile.displayName ?? "Not set"
                            )

                            ProfileDetailRow(
                                icon: "at",
                                label: "Username",
                                value: profile.username ?? "Not set"
                            )

                            ProfileDetailRow(
                                icon: "envelope.fill",
                                label: "Email",
                                value: profile.email ?? "Not set"
                            )

                            ProfileDetailRow(
                                icon: "phone.fill",
                                label: "Phone",
                                value: profile.phoneNumber ?? "Not set"
                            )

                            ProfileDetailRow(
                                icon: "number",
                                label: "User ID",
                                value: profile.id.uuidString
                            )
                            .font(.caption)
                        } else if profileManager.isLoading {
                            ProgressView("Loading profile...")
                                .padding()
                        } else {
                            Text("Unable to load profile")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
    }

    private var profileInitials: String {
        guard let profile = profileManager.profile else { return "?" }

        if let displayName = profile.displayName, !displayName.isEmpty {
            let components = displayName.split(separator: " ")
            if components.count >= 2 {
                return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
            } else if let first = components.first {
                return String(first.prefix(2)).uppercased()
            }
        }

        if let username = profile.username, !username.isEmpty {
            return String(username.prefix(2)).uppercased()
        }

        if let email = profile.email, !email.isEmpty {
            return String(email.prefix(2)).uppercased()
        }

        return "?"
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .frame(width: 24)

                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}
