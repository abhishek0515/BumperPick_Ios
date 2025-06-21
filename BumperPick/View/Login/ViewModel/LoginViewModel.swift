//
//  LoginModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 19/05/25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var countryCode = "+91"
    @Published var phoneNumber = "7498324730"
    @Published var isTermsAccepted = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var alertTitle = ""
    @Published var isLoading = false
    @Published var shouldNavigateAfterAlert = false
    @Published var loginViaGmail = false


    func validateAndLogin() {
        guard isCountryCodeValid(countryCode) else {
            alertTitle = "Invalid Country Code"
            alertMessage = "Please enter a valid country code (e.g., +1, +91)."
            showAlert = true
            return
        }

        guard isNumberValid(phoneNumber) else {
            alertTitle = "Invalid Number"
            alertMessage = "Please enter a valid 10-digit number."
            showAlert = true
            return
        }

        guard isTermsAccepted else {
            alertTitle = "Terms Required"
            alertMessage = "Please accept the Terms & Conditions."
            showAlert = true
            return
        }

        callLoginAPI()
    }

    private func isNumberValid(_ number: String) -> Bool {
        return number.count == 10 && number.allSatisfy(\.isNumber)
    }

    private func isCountryCodeValid(_ code: String) -> Bool {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        return trimmed.starts(with: "+") && trimmed.dropFirst().allSatisfy(\.isNumber)
    }

    private func callLoginAPI() {
        let urlString = AppString.baseUrl + AppString.sendOtpApi
        guard let url = URL(string: urlString) else { return }

        let fullPhoneNumber = "\(countryCode)\(phoneNumber)"
        let params = ["phone_number": fullPhoneNumber]
        let body = try? JSONSerialization.data(withJSONObject: params)

        isLoading = true

        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: LoginResponse.self
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("Login Success:", response.message)
                    self.alertTitle = "Success"
                    self.alertMessage = response.message
                    self.shouldNavigateAfterAlert = true
                    self.showAlert = true
                    self.loginViaGmail = false
                case .failure(let error):
                    print("Login Failed:", error.localizedDescription)
                    self.alertTitle = "Login Failed"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    self.loginViaGmail = true
                }
            }
        }
    }
    
    /// 🔹 New Function: Login using Google email
    func loginWithGoogle(email: String) {
        let urlString = AppString.baseUrl + AppString.googleLoginApi // <- Define this key in `AppString`
        guard let url = URL(string: urlString) else { return }

        let params = ["email": email]
        let body = try? JSONSerialization.data(withJSONObject: params)
        isLoading = true
        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: OTPVerifyResponse.self
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("Login Success:", response.message)
                    CustomerSession.shared.saveSession(from: response)
                    self.alertTitle = "Success"
                    self.alertMessage = response.message
                    self.showAlert = true
                    self.loginViaGmail = true
                case .failure(let error):
                    print("Login Failed:", error.localizedDescription)
                    self.alertTitle = "Login Failed"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}



struct LoginResponse: Decodable {
    let message: String
    let code: Int
}
