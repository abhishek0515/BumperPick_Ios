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

        
    func fetchCartOffers(customerId: Int, token: String) {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.cartOfferApi) else {
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
            responseType: CartResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.offers = response.data.map { $0.offer }
                    self?.cartItem = response.data

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

}
