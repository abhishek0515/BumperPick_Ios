//
//  HomeViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 01/07/25.
//
import Foundation


class CampaignRegistrationViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert: Bool = false
    @Published var registrationSuccess: Bool = false

    func submitForm(name: String, number: String, email: String, campaignID: Int) {
        // Input validation
        guard !name.isEmpty, !number.isEmpty, !email.isEmpty else {
            alertMessage = "All fields are required."
            showAlert = true
            return
        }

        guard isValidPhone(number) else {
            alertMessage = "Please enter a valid mobile number."
            showAlert = true
            return
        }

        guard isValidEmail(email) else {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }

        let urlString = AppString.baseUrl + AppString.campaignRegisterApi
        guard let url = URL(string: urlString) else {
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "campaign_id": campaignID,
            "name": name,
            "email": email,
            "phone": number
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            alertMessage = "Failed to encode request body."
            showAlert = true
            return
        }

        isLoading = true
        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: CampaignRegistrationResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    self?.alertMessage = response.message
                    self?.registrationSuccess = true
                    self?.showAlert = true

                case .failure(let error):
                    self?.registrationSuccess = false
                    switch error {
                    case let APIError.serverError(message):
                        self?.alertMessage = message
                    case let APIError.decodingError(decodingError, rawData):
                        self?.alertMessage = "Decoding Error: \(decodingError.localizedDescription)"
                        print("Raw JSON: \(String(data: rawData, encoding: .utf8) ?? "")")
                    default:
                        self?.alertMessage = error.localizedDescription
                    }
                    self?.showAlert = true
                }
            }
        }
    }
}
