//
//  HomeViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 10/06/25.
//
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didFetchData = false
    
    func fetchHomeData(categoryId: Int?, subcategoryId: Int?) {
        didFetchData = true

        let urlString = AppString.baseUrl + AppString.OfferCustomerApi
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }

        // Build request body with nil-safe values
        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "category_id": categoryId ?? "",
            "subcategory_id": subcategoryId ?? ""
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            self.errorMessage = "Failed to encode body"
            return
        }

        isLoading = true
        errorMessage = nil

        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: HomeDataResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                print("✅ Offers: \(response.offers.count), Categories: \(response.categories.count)")
                self.offers = response.offers.filter { !$0.expire! }
                self.categories = response.categories

            case .failure(let error):
                self.errorMessage = error.localizedDescription

                switch error {
                case let APIError.decodingError(decodingError, rawData):
                    print("❌ Decoding error: \(decodingError)")
                    if let raw = String(data: rawData, encoding: .utf8) {
                        print("🔍 Raw JSON: \(raw)")
                    }
                case let APIError.serverError(message):
                    print("❌ Server error: \(message)")
                case let APIError.unknown(err):
                    print("❌ Unknown error: \(err)")
                default:
                    print("❌ Error:", error.localizedDescription)
                }
            }
        }
    }

}
