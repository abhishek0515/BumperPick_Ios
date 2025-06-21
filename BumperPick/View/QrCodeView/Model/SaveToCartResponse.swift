//
//  SaveToCartResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 12/06/25.
//

import Foundation

struct SaveToCartResponse: Codable {
    let code: Int
    let message: String
    let data: CartData
}

struct CartData: Codable {
    let id: Int
    let customerId: String
    let offerId: String
    let status: String?
    let createAt: String
    let offer: OfferDetail

    enum CodingKeys: String, CodingKey {
        case id
        case customerId = "customer_id"
        case offerId = "offer_id"
        case status
        case createAt = "create_at"
        case offer
    }
}

struct OfferDetail: Codable {
    let id: Int
    let vendorId: Int
    let title: String
    let heading: String?
    let subheading: String?
    let discount: String
    let brandName: String?
    let brandLogoUrl: String?
    let description: String
    let terms: String
    let startDate: String
    let endDate: String
    let approval: String
    let quantity: Int
    let media: [OfferMedia]

    enum CodingKeys: String, CodingKey {
        case id
        case vendorId = "vendor_id"
        case title
        case heading
        case subheading
        case discount
        case brandName = "brand_name"
        case brandLogoUrl = "brand_logo_url"
        case description
        case terms
        case startDate = "start_date"
        case endDate = "end_date"
        case approval
        case quantity
        case media
    }
}

struct OfferMedia: Codable {
    let id: Int
    let type: String
    let url: String
}
