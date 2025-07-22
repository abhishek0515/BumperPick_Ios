//
//  FAQ.swift
//  BumperPick
//
//  Created by tauseef hussain on 15/07/25.
//
import Foundation

struct FAQResponse: Codable {
    let code: Int
    let message: String
    let data: [FAQItem]
}

struct FAQItem: Codable, Identifiable {
    let id: Int
    let question: String
    let answer: String
    let isCustomer: Int
    let isVendor: Int

    enum CodingKeys: String, CodingKey {
        case id, question, answer
        case isCustomer = "is_customer"
        case isVendor = "is_vendor"
    }
}
