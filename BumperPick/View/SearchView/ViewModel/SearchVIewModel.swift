//
//  SearchVIewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 14/07/25.
//
import Foundation

class SearchVIewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var didFetchData = false
    @Published var showAlert = false
    
    func fetchHomeData(categoryId: [Int], subcategoryId: Int?, distanceFilter: Int?, sortBy: String?, searchText: String?) {

        let urlString = AppString.baseUrl + AppString.OfferCustomerApi
        guard let url = URL(string: urlString) else {
            self.alertMessage = "Invalid URL"
            return
        }

        // Build request body with nil-safe values
        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "category_id":  categoryId,
            "subcategory_id": subcategoryId ?? "",
            "distance_filter": distanceFilter ?? 0,
            "sort_by": sortBy ?? "",
            "search": searchText ?? ""
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            self.alertMessage = "Failed to encode body"
            return
        }

        isLoading = true
        alertMessage = nil

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
                self.offers = response.offers
                self.categories = response.categories
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                print("failedResponseHome")

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
