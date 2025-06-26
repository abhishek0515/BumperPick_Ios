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
    let data: CartOfferData
}

struct CartOfferData: Codable {
    let id: Int
    let customerID: Int
    let offerID: String
    let status: String?
    let createAt: String
    let offer: Offer
}
