//
//  TrendingSearchViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 14/07/25.
//
import Foundation

class TrendingSearchViewModel: ObservableObject {
    @Published var trendingSearch:TrendingSearchResponse?
    @Published var isLoading = false
    @Published var alerMessage: String? = nil
    @Published var showAlert = false
    @Published var alertTitle: String = "Alert"

        
    func fetchTrendingSearch() {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.trendingSearchApi) else {
            self.alerMessage = "Invalid URL"
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: CustomerSession.shared.token ?? "")
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
                responseType: TrendingSearchResponse.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let response):
                       // self?.offers = response.data.map { $0.offer }
                        self?.trendingSearch = response
                    case .failure(let error):
                        if let apiError = error as? APIError {
                            self?.handleError(apiError)
                            self?.showAlert = true
                        } else {
                            self?.alerMessage = error.localizedDescription
                            self?.showAlert = true
                        }
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
