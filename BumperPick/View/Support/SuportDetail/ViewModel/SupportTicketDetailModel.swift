//
//  SupportTicketDetailModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/07/25.
//
import Foundation

class SupportTicketDetailModel: ObservableObject  {
    @Published var ticketResponse: SupportTicketDetail?
    @Published var ticketList: [TicketMessage] = []
    @Published var ticketReplyResponse: SupportTicketReplyResponse?

    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var alertTitle: String?

    @Published var showAlert = false
    
    func getTicketDetail(ticketID: String) {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.customerTicketApi + "/\(ticketID)") else {
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
            responseType: SupportTicketDetailResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.ticketResponse = response.data
                    self?.ticketList = response.data.messages
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
    
    
    func replyTicket(ticketID: String, message: String, completion: @escaping (Bool) -> Void) {
        let urlString = AppString.baseUrl + AppString.customerTicketApi + "/\(ticketID)/\(AppString.replyApi)"
        guard let url = URL(string: urlString) else {
            self.alertMessage = "Invalid URL"
            self.showAlert = true
            completion(false)
            return
        }

        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "message": message
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            self.alertMessage = "Failed to encode body"
            self.showAlert = true
            completion(false)
            return
        }

        isLoading = true
        alertMessage = nil

        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: SupportTicketReplyResponse.self
        ) { [weak self] result in
            guard let self = self else {
                completion(false)
                return
            }
            self.isLoading = false
            switch result {
            case .success(let response):
                self.ticketReplyResponse = response
                completion(true)
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showAlert = true
                switch error {
                case let APIError.decodingError(_, rawData):
                    if let raw = String(data: rawData, encoding: .utf8) {
                        self.alertMessage = raw
                    }
                case let APIError.serverError(message):
                    self.alertMessage = message
                case let APIError.unknown(err):
                    self.alertMessage = err.localizedDescription
                default:
                    break
                }
                completion(false)
            }
        }
    }

    
    func  isValidMessage(message: String) -> Bool {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let wordCount = trimmed.split { $0 == " " || $0.isNewline }.count
        return trimmed.count >= 10 && wordCount >= 5
    }
    
}
