//
//  ProfileManager.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/7/25.
//

import Foundation
import Supabase

@MainActor
class ProfileManager: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await Config.supabase.auth.session.user

            let profileData: Profile = try await Config.supabase
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .single()
                .execute()
                .value

            self.profile = Profile(
                id: user.id,
                username: profileData.username,
                email: user.email,
                displayName: (user.userMetadata["full_name"] as? String), // swiftlint:disable:this force_cast
                phoneNumber: user.phone?.isEmpty == true ? nil : user.phone
            )

            isLoading = false
        } catch {
            print("Error fetching profile: \(error)")
            errorMessage = "Failed to load profile"
            isLoading = false
        }
    }

    func updateProfile() async {
        guard let profile = profile else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Update profiles table (username)
            try await Config.supabase
                .from("profiles")
                .update(["username": profile.username ?? ""])
                .eq("id", value: profile.id.uuidString)
                .execute()

            // Update auth user metadata (display name)
            if let displayName = profile.displayName {
                let attributes = UserAttributes(
                    data: ["full_name": AnyJSON.string(displayName)]
                )
                try await Config.supabase.auth.update(user: attributes)
            }

            // TODO: Add separate verified flows for email and phone number updates

            isLoading = false
        } catch {
            print("Error updating profile: \(error)")
            errorMessage = "Failed to update profile"
            isLoading = false
        }
    }
}
