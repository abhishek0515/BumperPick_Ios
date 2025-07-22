//
//  Untitled.swift
//  BumperPick
//
//  Created by tauseef hussain on 04/07/25.
//
import Foundation

class EventViewModel: ObservableObject {
    @Published var event: [EventData] = []
    @Published var isLoading = false
    @Published var alerMessage: String? = nil
    @Published var showAlert = false

        
    func fetchEvent(token: String) {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.getEventApi) else {
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
            responseType: EventListResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.event = response.data
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
