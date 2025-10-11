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
                            IndividualEditableRow(
                                icon: "person.fill",
                                label: "Display Name",
                                value: profile.displayName ?? "",
                                placeholder: "Not set",
                                onSave: { newValue in
                                    await updateDisplayName(newValue)
                                }
                            )

                            UsernameEditableRow(
                                icon: "at",
                                label: "Username",
                                value: profile.username ?? "",
                                placeholder: "Not set",
                                currentUsername: profile.username,
                                profileManager: profileManager,
                                onSave: { newValue in
                                    await updateUsername(newValue)
                                }
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

    private func updateDisplayName(_ newValue: String) async {
        guard var profile = profileManager.profile else { return }
        profile.displayName = newValue.isEmpty ? nil : newValue
        profileManager.profile = profile
        await profileManager.updateProfile()
    }

    private func updateUsername(_ newValue: String) async {
        guard var profile = profileManager.profile else { return }
        profile.username = newValue.isEmpty ? nil : newValue
        profileManager.profile = profile
        await profileManager.updateProfile()
    }
}

struct IndividualEditableRow: View {
    let icon: String
    let label: String
    let value: String
    let placeholder: String
    let onSave: (String) async -> Void

    @State private var isEditing = false
    @State private var editedValue: String = ""

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

            HStack {
                if isEditing {
                    TextField(label, text: $editedValue)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                } else {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.body)
                        .foregroundColor(value.isEmpty ? .secondary : .primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: {
                    if isEditing {
                        Task {
                            await onSave(editedValue)
                            isEditing = false
                        }
                    } else {
                        editedValue = value
                        isEditing = true
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

struct UsernameEditableRow: View {
    let icon: String
    let label: String
    let value: String
    let placeholder: String
    let currentUsername: String?
    let profileManager: ProfileManager
    let onSave: (String) async -> Void

    @State private var isEditing = false
    @State private var editedValue: String = ""
    @State private var availabilityStatus: AvailabilityStatus = .idle
    @State private var checkTask: Task<Void, Never>?

    enum AvailabilityStatus {
        case idle
        case checking
        case available
        case unavailable
    }

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

            HStack {
                if isEditing {
                    TextField(label, text: $editedValue)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                        .onChange(of: editedValue) { newValue in
                            checkTask?.cancel()
                            availabilityStatus = .checking

                            checkTask = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce

                                guard !Task.isCancelled else { return }

                                if newValue.isEmpty || newValue == currentUsername {
                                    availabilityStatus = .idle
                                } else {
                                    let isAvailable = await profileManager.checkUsernameAvailability(newValue)
                                    guard !Task.isCancelled else { return }
                                    availabilityStatus = isAvailable ? .available : .unavailable
                                }
                            }
                        }

                    // Availability indicator
                    Group {
                        switch availabilityStatus {
                        case .idle:
                            EmptyView()
                        case .checking:
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        case .available:
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        case .unavailable:
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.body)
                        .foregroundColor(value.isEmpty ? .secondary : .primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: {
                    if isEditing {
                        if availabilityStatus == .available || editedValue == currentUsername {
                            Task {
                                await onSave(editedValue)
                                isEditing = false
                                availabilityStatus = .idle
                                checkTask?.cancel()
                            }
                        }
                    } else {
                        editedValue = value
                        isEditing = true
                        availabilityStatus = .idle
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .opacity(isEditing && availabilityStatus != .available && editedValue != currentUsername ? 0.3 : 1.0)
                }
                .disabled(isEditing && availabilityStatus != .available && editedValue != currentUsername)
            }
        }
        .onDisappear {
            checkTask?.cancel()
        }
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
