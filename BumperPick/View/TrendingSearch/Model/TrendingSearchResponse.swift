//
//  TrendingSearchResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 14/07/25.
//
import Foundation

struct TrendingSearchResponse: Codable {
    let code: Int
    let message: String
    let data: [String]
}
