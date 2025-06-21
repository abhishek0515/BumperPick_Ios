//
//  CategoryResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/06/25.
//


import Foundation

struct CategoryResponse: Codable {
    let code: Int
    let message: String
    let data: [Category]
}

