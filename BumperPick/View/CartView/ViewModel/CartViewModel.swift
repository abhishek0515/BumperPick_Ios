//
//  CartViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 12/06/25.
//


import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var isLoading = false
    @Published var alerMessage: String? = nil
    @Published var cartItem: [CartItem] = []
    @Published var showAlert = false
    @Published var favouriteOffer: [FavouriteOffer] = []
    @Published var alertTitle: String = "Alert"

        
    func fetchOffers(customerId: Int, token: String, api: String, isFavourite: Bool) {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + api) else {
            self.alerMessage = "Invalid URL"
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: token)
        ]

        guard let url = urlComponents.url else {
            self.alerMessage = "Invalid URL components"
            return
        }

        isLoading = true
        alerMessage = nil

        if isFavourite {
            APIManager.shared.request(
                url: url,
                method: "GET",
                headers: ["Accept": "application/json"],
                responseType: FavouriteListResponse.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let response):
                        print("favourite success")
                        self?.favouriteOffer = response.data
                    case .failure(let error):
                        if let apiError = error as? APIError {
                            self?.handleError(apiError)
                        } else {
                            self?.alerMessage = error.localizedDescription
                            self?.showAlert = true
                        }
                    }
                }
            }
        } else {
            APIManager.shared.request(
                url: url,
                method: "GET",
                headers: ["Accept": "application/json"],
                responseType: CartResponse.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let response):
                        self?.offers = response.data.map { $0.offer }
                        self?.cartItem = response.data
                    case .failure(let error):
                        if let apiError = error as? APIError {
                            self?.handleError(apiError)
                        } else {
                            self?.alerMessage = error.localizedDescription
                            self?.showAlert = true
                        }
                    }
                }
            }
        }
    }

        
    func deleteCartOffer(cartId: Int, token: String) {
        let urlString = AppString.baseUrl + AppString.deleteCartOfferApi + "\(cartId)"
        guard var urlComponents = URLComponents(string: urlString) else {
            self.alerMessage = "Invalid URL"
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: token)
        ]

        guard let url = urlComponents.url else {
            self.alerMessage = "Invalid URL components"
            return
        }

        isLoading = true
        alerMessage = nil

        APIManager.shared.request(
            url: url,
            method: "GET",
            headers: ["Accept": "application/json"],
            responseType: CartDeleteResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.cartItem.removeAll { $0.id == cartId }
                    self?.alerMessage = response.message
                    self?.showAlert = true

                case .failure(let error):
                    self?.showAlert = true
                    switch error {
                    case APIError.decodingError(_, let rawData):
                        self?.alerMessage = String(data: rawData, encoding: .utf8) ?? "Decoding error"
                    case APIError.serverError(let message):
                        self?.alerMessage = message
                    case APIError.unknown(let err):
                        self?.alerMessage = err.localizedDescription
                    default:
                        self?.alerMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func faverouiteTogelApi(offerId: String) {
        
        let urlString = AppString.baseUrl + AppString.favrouiteApi
        guard let url = URL(string: urlString) else {
            self.alerMessage = "Invalid URL"
            return
        }

        // Build request body with nil-safe values
        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "promotion_id": offerId
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            self.alerMessage = "Failed to encode body"
            return
        }

        isLoading = true
        alerMessage = nil

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
                self.favouriteOffer.removeAll { $0.id == Int(offerId) }
                showAlert = true
                self.alerMessage = response.message
            case .failure(let error):
                showAlert = true
                self.alerMessage = error.localizedDescription
                print("failedResponseHome")

                switch error {
                case let APIError.decodingError(decodingError, rawData):
                    print("❌ Decoding error: \(decodingError)")
                    if let raw = String(data: rawData, encoding: .utf8) {
                        self.alerMessage = raw
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
    
    private func handleError(_ error: APIError) {
            self.showAlert = true
            switch error {
            case .decodingError(_, let rawData):
                self.alerMessage = String(data: rawData, encoding: .utf8) ?? "Decoding error"
            case .serverError(let message):
                self.alerMessage = message
            case .unknown(let err):
                self.alerMessage = err.localizedDescription
            default:
                self.alerMessage = error.localizedDescription
            }
        }

}


//class CartViewModel: ObservableObject {
//    @Published var offers: [Offer] = []
//    @Published var isLoading = false
//    @Published var alerMessage: String? = nil
//    @Published var cartItem: [CartItem] = []
//    @Published var showAlert = false
//
//        
//    func fetchOffers(customerId: Int, token: String, api: String) {
//        guard var urlComponents = URLComponents(string: AppString.baseUrl + api) else {
//            self.alerMessage = "Invalid URL"
//            return
//        }
//
//        urlComponents.queryItems = [
//            URLQueryItem(name: "token", value: token)
//        ]
//
//        guard let url = urlComponents.url else {
//            self.alerMessage = "Invalid URL components"
//            return
//        }
//
//        isLoading = true
//        alerMessage = nil
//
//        APIManager.shared.request(
//            url: url,
//            method: "GET",
//            headers: ["Accept": "application/json"],
//            responseType: CartResponse.self
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let response):
//                    self?.offers = response.data.map { $0.offer }
//                    self?.cartItem = response.data
//
//                case .failure(let error):
//                    self?.showAlert = true
//                    switch error {
//                    case APIError.decodingError(_, let rawData):
//                        self?.alerMessage = String(data: rawData, encoding: .utf8) ?? "Decoding error"
//                    case APIError.serverError(let message):
//                        self?.alerMessage = message
//                    case APIError.unknown(let err):
//                        self?.alerMessage = err.localizedDescription
//                    default:
//                        self?.alerMessage = error.localizedDescription
//                    }
//                }
//            }
//        }
//    }
//
//        
//    func deleteCartOffer(cartId: Int, token: String) {
//        let urlString = AppString.baseUrl + AppString.deleteCartOfferApi + "\(cartId)"
//        guard var urlComponents = URLComponents(string: urlString) else {
//            self.alerMessage = "Invalid URL"
//            return
//        }
//
//        urlComponents.queryItems = [
//            URLQueryItem(name: "token", value: token)
//        ]
//
//        guard let url = urlComponents.url else {
//            self.alerMessage = "Invalid URL components"
//            return
//        }
//
//        isLoading = true
//        alerMessage = nil
//
//        APIManager.shared.request(
//            url: url,
//            method: "GET",
//            headers: ["Accept": "application/json"],
//            responseType: CartDeleteResponse.self
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let response):
//                    self?.cartItem.removeAll { $0.id == cartId }
//                    self?.alerMessage = response.message
//                    self?.showAlert = true
//
//                case .failure(let error):
//                    self?.showAlert = true
//                    switch error {
//                    case APIError.decodingError(_, let rawData):
//                        self?.alerMessage = String(data: rawData, encoding: .utf8) ?? "Decoding error"
//                    case APIError.serverError(let message):
//                        self?.alerMessage = message
//                    case APIError.unknown(let err):
//                        self?.alerMessage = err.localizedDescription
//                    default:
//                        self?.alerMessage = error.localizedDescription
//                    }
//                }
//            }
//        }
//    }
//
//}
