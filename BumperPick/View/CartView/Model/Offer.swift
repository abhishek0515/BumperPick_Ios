//
//  Offer.swift
//  BumperPick
//
//  Created by tauseef hussain on 12/06/25.
//
import Foundation

struct CartResponse: Codable {
    let code: Int
    let message: String
    let data: [CartItem]
}

struct CartItem: Codable, Identifiable {
    let id: Int
    let customerId: Int
    let offerId: Int
    let status: Int
    let createAt: String
    let offer: Offer

    enum CodingKeys: String, CodingKey {
        case id
        case customerId = "customer_id"
        case offerId = "offer_id"
        case status
        case createAt = "create_at"
        case offer
    }
}

//Cart delete response --
struct CartDeleteResponse: Codable {
    let code: Int
    let message: String
    let data: CartItem
}

//MARK: for favourite response

struct FavouriteListResponse: Codable {
    let data: [FavouriteOffer]
    let code: Int
}

struct FavouriteOffer: Codable, Identifiable {
    let id: Int
    let vendorID: Int
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
    let reviews: [OfferReview]?
    let isFavourited: Bool?
    let isUnlimited: Int?
    let averageRating: String?

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
        case approval, quantity, expire, status, media, reviews
        case isFavourited = "is_favourited"
        case isUnlimited = "is_unlimited"
        case averageRating = "average_rating"
    }
}

extension FavouriteOffer {
    func toOffer() -> Offer {
        return Offer(
            id: id,
            vendorID: vendorID,
            subCategoryID: subCategoryID,
            offerTemplate: offerTemplate,
            imageAppearance: imageAppearance,
            title: title,
            heading: heading,
            subheading: subheading,
            discount: discount,
            brandName: brandName,
            brandLogoURL: brandLogoURL,
            description: description,
            terms: terms,
            startDate: startDate,
            endDate: endDate,
            approval: approval,
            quantity: quantity,
            expire: expire,
            status: status,
            media: media,
            isAds: nil,
            bannerImage: nil,
            average_rating: averageRating,
            isUnlimited: isUnlimited,
            reviews: reviews,
            isFavourited: isFavourited
        )
    }
}
