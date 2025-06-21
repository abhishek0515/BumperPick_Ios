//
//  VerifyOtpViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/05/25.
//


import SwiftUI
import Combine

// Dummy Response Struct (replace with your real API response model)
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
        // Check if all OTP fields are filled
        //           guard otpFields.allSatisfy({ !$0.trimmingCharacters(in: .whitespaces).isEmpty }) else {
        //               alertMessage = "Please enter the complete 4-digit OTP."
        //               showAlert = true
        //               return
        //           }
        //
        //           let otp = otpFields.joined()
        
        isLoading = true
        let urlString = AppString.baseUrl + AppString.verifyOtpApi
        // Example API Call (replace URL and logic with your real API)
        guard let url = URL(string: urlString) else {
            isLoading = false
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = ["phone_number": phoneNumber, "otp": otp]
        //        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let body = try? JSONSerialization.data(withJSONObject: params)
        
        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: OTPVerifyResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.code == 200 {
                        CustomerSession.shared.saveSession(from: response)
                        print("customerid  :\(CustomerSession.shared.customerID ?? 0)")
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
                            self.alertMessage = rawString
                            print("❗️Raw response:\n\(rawString)")
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
    }
            
    func resendOtp() {
        isLoading = true
        let urlString = AppString.baseUrl + AppString.resendOtpApi
        guard let url = URL(string: urlString) else {
            isLoading = false
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = ["phone_number": phoneNumber]
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.alertMessage = error.localizedDescription
                    self?.showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.alertMessage = "No data received"
                    self?.showAlert = true
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(ResendResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.code == 200 {
                        self?.alertMessage = "OTP has been resent"
                    } else {
                        self?.alertMessage = response.message
                    }
                    self?.showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self?.alertMessage = "Failed to parse response"
                    self?.showAlert = true
                }
            }
        }.resume()
    }
}

struct ResendResponse: Decodable {
    let code: Int
    let message: String
}
