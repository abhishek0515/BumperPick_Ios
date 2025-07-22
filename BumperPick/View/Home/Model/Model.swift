//
//  Model.swift
//  BumperPick
//
//  Created by tauseef hussain on 10/06/25.
//

import Foundation
import SwiftUI

struct HomeDataResponse: Codable {
    let code: Int
    let message: String
    let offers: [Offer]
    let categories: [Category]
}

struct Offer: Codable, Identifiable {
    let id: Int?
    let vendorID: Int?
    let subCategoryID: Int?
    let offerTemplate: String?
    let imageAppearance: String?
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
    let isAds: Bool?
    let bannerImage: String?
    let average_rating: String?
    let isUnlimited: Int?
    let reviews: [OfferReview]?
    var isFavourited: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case vendorID = "vendor_id"
        case subCategoryID = "sub_category_id"
        case offerTemplate = "offer_template"
        case imageAppearance = "image_appearance"
        case title, heading, subheading, discount
        case brandName = "brand_name"
        case brandLogoURL = "brand_logo_url"
        case description, terms
        case startDate = "start_date"
        case endDate = "end_date"
        case approval, quantity, expire, status, media
        case isAds = "is_ads"
        case bannerImage = "banner_image"
        case average_rating
        case isUnlimited = "is_unlimited"
        case reviews
        case isFavourited = "is_favourited"
    }
}

struct Media: Codable, Identifiable {
    let id: Int?
    let type: String?
    let url: String?
}

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

//MARK: favrouite response
struct FavouriteResponse: Codable {
    let code: Int
    let message: String
    let promotionID: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case promotionID = "promotion_id"
        case status
    }
}


struct ExploreCampaignCard: Identifiable {
    let id = UUID() // ✅ Add this line
    let title: String
    let imageName: String
    let backgroundColor: Color
    let borderColor: Color
}
