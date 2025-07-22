//
//  OfferDetailViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 08/07/25.
//

import Foundation


class OfferDetailViewModel: ObservableObject {
    @Published var offer: OfferDetail?
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var dismissAfterSuccess = false

    
    func fetchOfferDetails(offerID: String) {
        let urlString = AppString.baseUrl + AppString.offerDetailsApies +  "/\(offerID)"
        guard var urlComponents = URLComponents(string: urlString) else {
            self.alertMessage = "Invalid URL"
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: CustomerSession.shared.token ?? "")
        ]

        guard let url = urlComponents.url else {
            self.alertMessage = "Invalid URL components"
            return
        }

        isLoading = true
        alertMessage = nil

        APIManager.shared.request(
            url: url,
            method: "GET",
            headers: ["Accept": "application/json"],
            responseType: OfferDetailResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.offer = response.data
                case .failure(let error):
                    self?.showAlert = true
                    switch error {
                    case APIError.decodingError(_, let rawData):
                        self?.alertMessage = String(data: rawData, encoding: .utf8) ?? "Decoding error"
                    case APIError.serverError(let message):
                        self?.alertMessage = message
                    case APIError.unknown(let err):
                        self?.alertMessage = err.localizedDescription
                    default:
                        self?.alertMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func sendFeedbackAndRating(rating: String, comment: String, offerID: String) {

        let urlString = AppString.baseUrl + AppString.feddbackRatingApi
        guard let url = URL(string: urlString) else {
            self.alertMessage = "Invalid URL"
            return
        }

        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "promotion_id": offerID,
            "rating": rating,
            "review": comment
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
            responseType: ReviewResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                self.alertMessage = response.message
                self.showAlert = true
                self.dismissAfterSuccess = true
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                print("failedResponseHome")
                self.showAlert = true
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
    
    func faverouiteTogelApi(offerId: String) {
        
        let urlString = AppString.baseUrl + AppString.favrouiteApi
        guard let url = URL(string: urlString) else {
            self.alertMessage = "Invalid URL"
            return
        }

        // Build request body with nil-safe values
        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "promotion_id": offerId
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
            responseType: FavouriteResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
              //  self.handleFavouriteResponse(response)
                showAlert = true
                self.alertMessage = response.message
                self.dismissAfterSuccess = false
                // Update offer.isFavourited based on status
                if response.status == "added" {
                    self.offer?.isFavourited = true
                } else if response.status == "removed" {
                    self.offer?.isFavourited = false
                }

            case .failure(let error):
                showAlert = true
                self.alertMessage = error.localizedDescription
                print("failedResponseHome")

                switch error {
                case let APIError.decodingError(decodingError, rawData):
                    print("❌ Decoding error: \(decodingError)")
                    if let raw = String(data: rawData, encoding: .utf8) {
                        self.alertMessage = raw
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
