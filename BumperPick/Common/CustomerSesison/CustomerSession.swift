//
//  CustomerSession.swift
//  BumperPick
//
//  Created by tauseef hussain on 10/06/25.
//
import SwiftUI

import Foundation
import Combine

//final class CustomerSession: ObservableObject {
//    static let shared = CustomerSession()
//
//    // MARK: - Published Properties
//    @Published var token: String?
//    @Published var customerID: Int?
//    @Published var isLoggedIn: Bool {
//        didSet {
//            UserDefaults.standard.set(isLoggedIn, forKey: "customerIsLoggedIn")
//        }
//    }
//    @Published var isSessionLoaded: Bool = false
//
//    private let sessionKey = "CustomerOTPVerifyResponse"
//
//    // MARK: - Init
//    private init() {
//        self.isLoggedIn = UserDefaults.standard.bool(forKey: "customerIsLoggedIn")
//        loadSessionFromDefaults()
//    }
//
//    // MARK: - Save Session
//    func saveSession(from response: OTPVerifyResponse) {
//        DispatchQueue.main.async {
//            self.token = response.meta.token
//            self.customerID = response.data.customerId
//            self.isLoggedIn = true
//
//            self.saveToUserDefaults(response)
//        }
//    }
//
//    // MARK: - Save to UserDefaults
//    private func saveToUserDefaults(_ response: OTPVerifyResponse) {
//        do {
//            let encoded = try JSONEncoder().encode(response)
//            UserDefaults.standard.set(encoded, forKey: sessionKey)
//            print("✅ Customer session saved to UserDefaults.")
//        } catch {
//            print("❌ Failed to encode customer session:", error)
//        }
//    }
//
//    // MARK: - Load from UserDefaults
//    private func loadSessionFromDefaults() {
//        guard let data = UserDefaults.standard.data(forKey: sessionKey) else {
//            print("ℹ️ No customer session data found.")
//            isSessionLoaded = true
//            return
//        }
//
//        do {
//            let decoded = try JSONDecoder().decode(OTPVerifyResponse.self, from: data)
//            print("✅ Customer session loaded from UserDefaults.")
//            saveSession(from: decoded)
//        } catch {
//            print("❌ Failed to decode customer session:", error)
//        }
//
//        isSessionLoaded = true
//    }
//
//    // MARK: - Clear Session
//    func clearSession() {
//        DispatchQueue.main.async {
//            self.token = nil
//            self.customerID = nil
//            self.isLoggedIn = false
//
//            UserDefaults.standard.removeObject(forKey: self.sessionKey)
//            UserDefaults.standard.set(false, forKey: "customerIsLoggedIn")
//
//            print("🧹 Customer session cleared.")
//        }
//    }
//
//    // MARK: - Public Logout API
//    func logout() {
//        clearSession()
//    }
//}


//final class CustomerSession: ObservableObject {
//    static let shared = CustomerSession()
//
//    @Published var token: String?
//    @Published var customerID: Int?
//    @Published var isLoggedIn: Bool = false {
//        didSet {
//            UserDefaults.standard.set(isLoggedIn, forKey: "customerIsLoggedIn")
//        }
//    }
//    @Published var isSessionLoaded: Bool = false
//
//    private let sessionKey = "CustomerOTPVerifyResponse"
//
//    private init() {
//        // Directly read UserDefaults to keep initial value
//        if let data = UserDefaults.standard.data(forKey: sessionKey),
//           let decoded = try? JSONDecoder().decode(OTPVerifyResponse.self, from: data) {
//            token = decoded.meta.token
//            customerID = decoded.data.customerId
//            isLoggedIn = true
//        } else {
//            isLoggedIn = false
//        }
//
//        isSessionLoaded = true
//    }
//
//    // Save session after login
//    func saveSession(from response: OTPVerifyResponse) {
//        token = response.meta.token
//        customerID = response.data.customerId
//        isLoggedIn = true
//
//        do {
//            let encoded = try JSONEncoder().encode(response)
//            UserDefaults.standard.set(encoded, forKey: sessionKey)
//        } catch {
//            print("❌ Failed to save session:", error)
//        }
//    }
//
//    // Clear session
//    func clearSession() {
//        token = nil
//        customerID = nil
//        isLoggedIn = false
//
//        UserDefaults.standard.removeObject(forKey: sessionKey)
//        UserDefaults.standard.set(false, forKey: "customerIsLoggedIn")
//
//        print("🧹 Customer session cleared.")
//    }
//
//    // Logout
//    func logout() {
//        clearSession()
//    }
//}


enum LoginMethod: String, Codable {
    case phone
    case google
}

final class CustomerSession: ObservableObject {
    static let shared = CustomerSession()

    @Published var token: String?
    @Published var customerID: Int?
    @Published var isLoggedIn: Bool = false {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "customerIsLoggedIn")
        }
    }
    @Published var isSessionLoaded: Bool = false
    @Published var loginMethod: LoginMethod? = nil

    private let sessionKey = "CustomerOTPVerifyResponse"
    private let loginMethodKey = "CustomerLoginMethod"

    private init() {
        if let data = UserDefaults.standard.data(forKey: sessionKey),
           let decoded = try? JSONDecoder().decode(OTPVerifyResponse.self, from: data) {
            token = decoded.meta.token
            customerID = decoded.data.customerId
            isLoggedIn = true
        }

        if let methodRaw = UserDefaults.standard.string(forKey: loginMethodKey),
           let method = LoginMethod(rawValue: methodRaw) {
            loginMethod = method
        }

        isSessionLoaded = true
    }

    func saveSession(from response: OTPVerifyResponse, method: LoginMethod) {
        token = response.meta.token
        customerID = response.data.customerId
        isLoggedIn = true
        loginMethod = method

        // Save session & method
        do {
            let encoded = try JSONEncoder().encode(response)
            UserDefaults.standard.set(encoded, forKey: sessionKey)
            UserDefaults.standard.set(method.rawValue, forKey: loginMethodKey)
        } catch {
            print("❌ Failed to save session:", error)
        }
    }

    func clearSession() {
        token = nil
        customerID = nil
        isLoggedIn = false
        loginMethod = nil

        UserDefaults.standard.removeObject(forKey: sessionKey)
        UserDefaults.standard.removeObject(forKey: loginMethodKey)
        UserDefaults.standard.set(false, forKey: "customerIsLoggedIn")
        print("🧹 Customer session cleared.")
    }

    func logout() {
        clearSession()
    }
}
