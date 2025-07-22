//
//  CartViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 01/07/25.
//
import Foundation

class CampaignViewModel: ObservableObject {
    @Published var ongoingCampaign: [CustomerCampaign] = []
    @Published var yourCampaign: [CustomerCampaign] = []
    @Published var isLoading = false
    @Published var alerMessage: String? = nil
    @Published var showAlert = false

        
    func fetchCampaign(token: String) {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.getCampaignApi) else {
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
            responseType: CustomerCampaignResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.ongoingCampaign = response.data
                    self?.yourCampaign = response.data.filter { $0.isRegistered }
                case .failure(let error):
                    self?.showAlert = true
                    switch error {
                    case APIError.decodingError(_, let rawData):
                      //  self?.alerMessage = String(data: rawData, encoding: .utf8) ?? "Decoding error"
                        if let rawString = String(data: rawData, encoding: .utf8) {
                            print("📦 Decoding error raw response:\n\(rawString)")
                            self?.alerMessage = rawString
                        }
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
