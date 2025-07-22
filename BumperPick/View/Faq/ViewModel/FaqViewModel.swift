//
//  FaqViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/07/25.
//
import Foundation

class FaqViewModel: ObservableObject {
    @Published var faqData: [FAQItem] = []
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    
    func getFaq() {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.faqApi) else {
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
                responseType: FAQResponse.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let response):
                        self?.faqData = response.data
                    case .failure(let error):
                        if let apiError = error as? APIError {
                            self?.handleError(apiError)
                        } else {
                            self?.alertMessage = error.localizedDescription
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
                self.alertMessage = String(data: rawData, encoding: .utf8) ?? "Decoding error"
            case .serverError(let message):
                self.alertMessage = message
            case .unknown(let err):
                self.alertMessage = err.localizedDescription
            default:
                self.alertMessage = error.localizedDescription
            }
        }

}
