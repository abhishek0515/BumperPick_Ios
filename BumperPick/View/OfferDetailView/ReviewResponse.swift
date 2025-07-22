//
//  Model.swift
//  BumperPick
//
//  Created by tauseef hussain on 08/07/25.
//
import Foundation

struct ReviewResponse: Codable {
    let code: Int
    let message: String
    let data: ReviewData
}

struct ReviewData: Codable {
    let id: Int
    let promotionID: String
    let customerID: Int
    let rating: String
    let review: String?

    enum CodingKeys: String, CodingKey {
        case id
        case promotionID = "promotion_id"
        case customerID = "customer_id"
        case rating
        case review
    }
}

//MARK: OfferDetail Response
struct OfferDetailResponse: Codable {
    let code: Int
    let message: String
    let data: OfferDetail
}

struct OfferDetail: Codable {
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
    let averageRating: String?
    let approval: String?
    let quantity: Int?
    let isUnlimited: Int?
    let expire: Bool?
    let status: String?
    let media: [OfferMedia]?
    let reviews: [OfferReview]?
    var isFavourited: Bool
    let openingTime: String?
    let closingTime: String?
    let phone_number: String?
    let is_reviewed: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case vendorID = "vendor_id"
        case subCategoryID = "sub_category_id"
        case offerTemplate = "offer_template"
        case imageAppearance = "image_appearance"
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
        case averageRating = "average_rating"
        case approval
        case quantity
        case isUnlimited = "is_unlimited"
        case expire
        case status
        case media
        case reviews
        case isFavourited = "is_favourited"
        case openingTime = "opening_time"
        case closingTime = "closing_time"
        case phone_number
        case is_reviewed
    }
}

struct OfferMedia: Codable {
    let id: Int?
    let type: String?
    let url: String?
}

struct OfferReview: Codable {
    let customerId: Int?
    let id: Int?
    let promotionId: Int?
    let review: String?
    let rating: Int?
    let customer_name: String?

    enum CodingKeys: String, CodingKey {
        case customerId = "customer_id"
        case id
        case promotionId = "promotion_id"
        case review
        case rating
        case customer_name
    }
}

