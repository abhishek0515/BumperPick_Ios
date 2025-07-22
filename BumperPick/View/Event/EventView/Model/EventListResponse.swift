//
//  EventListResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 04/07/25.
//


import Foundation

struct EventListResponse: Codable {
    let code: Int
    let message: String
    let data: [EventData]
}

struct EventData: Codable, Identifiable {
    let id: Int
    let vendorID: Int
    let bannerImageURL: String?
    let title: String
    let description: String?
    let address: String
    let facebookLink: String?
    let instagramLink: String?
    let youtubeLink: String?
    let startDate: String
    let startTime: String
    let endDate: String?
    let endTime: String?
    let approval: String?
    let expire: Bool
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case vendorID = "vendor_id"
        case bannerImageURL = "banner_image_url"
        case title
        case description
        case address
        case facebookLink = "facebook_link"
        case instagramLink = "instagram_link"
        case youtubeLink = "youtube_link"
        case startDate = "start_date"
        case startTime = "start_time"
        case endDate = "end_date"
        case endTime = "end_time"
        case approval
        case expire
        case status
    }
}
