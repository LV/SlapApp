//
//  Profile.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/7/25.
//

import Foundation

struct Profile: Codable {
    let id: UUID
    var username: String?
    var email: String?
    var displayName: String?
    var phoneNumber: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case displayName = "display_name"
        case phoneNumber = "phone_number"
    }
}
