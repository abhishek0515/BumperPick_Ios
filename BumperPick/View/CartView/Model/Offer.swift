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
