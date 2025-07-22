//
//  CustomerEventResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 01/07/25.
//
import Foundation

struct CustomerCampaignResponse: Codable {
    let code: Int
    let message: String
    let data: [CustomerCampaign]
}

struct CustomerCampaign: Codable, Identifiable {
    let id: Int
    let vendorID: Int
    let bannerImageURL: String?
    let title: String
    let description: String
    let address: String
    let numberOfParticipant: Int
    let startDate: String
    let endDate: String
    let approval: String?
    let expire: Bool
    let status: String
    let totalRegistered: Int
    let isRegistered: Bool
    let vendor: VendorInfo

    enum CodingKeys: String, CodingKey {
        case id
        case vendorID = "vendor_id"
        case bannerImageURL = "banner_image_url"
        case title
        case description
        case address
        case numberOfParticipant = "number_of_participant"
        case startDate = "start_date"
        case endDate = "end_date"
        case approval
        case expire
        case status
        case totalRegistered = "total_registered"
        case isRegistered = "is_registered"
        case vendor
    }
}

struct VendorInfo: Codable {
    let name: String?
    let establishmentName: String
    let brandName: String
    let phoneNumber: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case name
        case establishmentName = "establishment_name"
        case brandName = "brand_name"
        case phoneNumber = "phone_number"
        case email
    }
}
