//
//  UserProfileResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 18/06/25.
//
import Foundation

struct UserProfileResponse: Codable {
    let data: UserProfile?
    let code: Int
    let message: String
}

struct UserProfile: Codable {
    let id: Int
    let imageURL: String?
    let name: String?
    let phoneNumber: String
    let email: String?

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
        case name
        case phoneNumber = "phone_number"
        case email
    }
}
