//
//  EventRegistrationResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 01/07/25.
//
import Foundation

struct CampaignRegistrationResponse: Codable {
    let code: Int
    let message: String
    let data: CampaignRegistrationData
}

struct CampaignRegistrationData: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let campaignID: Int
    let vendorID: Int
    let bannerImageURL: String
    let title: String
    let description: String
    let address: String
    let numberOfParticipant: Int?
    let startDate: String
    let endDate: String
    let approval: String
    let expire: Bool
    let status: String

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone
        case campaignID = "campaign_id"
        case vendorID = "vendor_id"
        case bannerImageURL = "banner_image_url"
        case title, description, address
        case numberOfParticipant = "number_of_participant"
        case startDate = "start_date"
        case endDate = "end_date"
        case approval, expire, status
    }
}
