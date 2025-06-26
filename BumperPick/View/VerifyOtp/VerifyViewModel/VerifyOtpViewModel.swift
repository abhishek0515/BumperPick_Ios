//
//  VerifyOtpViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/05/25.
//


import SwiftUI
import Combine


struct VerifyOtpResponse: Decodable {
    let success: Bool
    let message: String
}

class VerifyOtpViewModel: ObservableObject {
    @Published var otpFields = ["", "", "", ""]
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var navigateToHome = false

    var phoneNumber: String
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }

    func verifyOtp() {
        let otp = otpFields.joined()
        guard !otp.isEmpty else {
            alertMessage = "Please enter OTP."
            showAlert = true
            return
        }

        let urlString = AppString.baseUrl + AppString.verifyOtpApi
        guard let url = URL(string: urlString) else {
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        let params = ["phone_number": phoneNumber, "otp": otp]
        let body = try? JSONSerialization.data(withJSONObject: params)

        isLoading = true

        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: OTPVerifyResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                if response.code == 200 {
                    CustomerSession.shared.saveSession(from: response)
                    self.navigateToHome = true
                } else {
                    self.alertMessage = response.message
                    self.showAlert = true
                }

            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showAlert = true

                switch error {
                case let APIError.decodingError(decodingError, rawData):
                    print("Decoding error:", decodingError)
                    if let rawString = String(data: rawData, encoding: .utf8) {
                        print("❗️Raw response:\n\(rawString)")
                        self.alertMessage = rawString
                    }

                case let APIError.serverError(message):
                    print("Server error:", message)

                case let APIError.unknown(err):
                    print("Unknown error:", err)

                default:
                    print("Request failed:", error)
                }
            }
        }
    }

    func resendOtp() {
        let urlString = AppString.baseUrl + AppString.resendOtpApi
        guard let url = URL(string: urlString) else {
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        let params = ["phone_number": phoneNumber]
        let body = try? JSONSerialization.data(withJSONObject: params)

        isLoading = true

        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: ResendResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                if response.code == 200 {
                    self.alertMessage = "OTP has been resent"
                } else {
                    self.alertMessage = response.message
                }
                self.showAlert = true

            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }
}


struct ResendResponse: Decodable {
    let code: Int
    let message: String
}
