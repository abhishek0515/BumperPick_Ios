//
//  SupportViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/07/25.
//

import Foundation

class SupportViewModel: ObservableObject {
    @Published var ticketResponse: SupportTicketResponse?
    @Published var ticketList: [SupportTicketItem] = []

    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    
    func getTicket() {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.customerTicketApi) else {
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
                responseType: SupportTicketListResponse.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let response):
                        self?.ticketList = response.data
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


    func submitTicket(subject: String, message: String) {
        let urlString = AppString.baseUrl + AppString.ticketCreateApi
        guard let url = URL(string: urlString) else {
            self.alertMessage = "Invalid URL"
            return
        }

        // Build request body with nil-safe values
        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "subject":  subject,
            "message": message
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
            responseType: SupportTicketResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                self.ticketResponse = response
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                print("failedResponseHome")
                self.showAlert = true
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
