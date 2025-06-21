//
//  Model.swift
//  BumperPick
//
//  Created by tauseef hussain on 10/06/25.
//

import Foundation

struct HomeDataResponse: Codable {
    let code: Int
    let message: String
    let offers: [Offer]
    let categories: [Category]
}

// MARK: - Offer
struct Offer: Codable {
    let id: Int?
    let vendorID: Int?
    let title: String?
    let heading: String?
    let subheading: String?
    let discount: String?
    let brandName: String?
    let brandLogoURL: String?
    let description: String?
    let terms: String?
    let startDate: String?
    let endDate: String?
    let approval: String?
    let quantity: Int?
    let expire: Bool?
    let status: String?
    let media: [Media]?

    enum CodingKeys: String, CodingKey {
        case id
        case vendorID = "vendor_id"
        case title
        case heading
        case subheading
        case discount
        case brandName = "brand_name"
        case brandLogoURL = "brand_logo_url"
        case description
        case terms
        case startDate = "start_date"
        case endDate = "end_date"
        case approval
        case quantity
        case expire
        case status
        case media
    }
}

// MARK: - Media
struct Media: Codable {
    let id: Int?
    let type: String?
    let url: String?
}

// MARK: - Category
struct Category: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let imageURL: String?
    let subCategories: [SubCategory]

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case imageURL = "image_url"
        case subCategories = "sub_categories"
    }
}

// MARK: - SubCategory
struct SubCategory: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case imageURL = "image_url"
    }
}


