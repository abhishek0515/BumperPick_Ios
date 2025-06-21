//
//  Untitled.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/05/25.
//

import Foundation


struct OTPVerifyResponse: Codable {
    let data: CustomerData
    let code: Int
    let message: String
    let meta: MetaData
}

struct CustomerData: Codable {
    let customerId: Int

    enum CodingKeys: String, CodingKey {
        case customerId = "customer_id"
    }
}

struct MetaData: Codable {
    let token: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case token
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
