//
//  AccountViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 18/06/25.
//
import Foundation

class AccountViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var alerMessage: String?
    @Published var isLoading = false
    @Published var showAlert = false
    
//    func fetchProfile(token: String) {
//        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.customerProfile) else {
//           self.alerMessage = "Invalid URL"
//           return
//       }
//
//       urlComponents.queryItems = [
//           URLQueryItem(name: "token", value: CustomerSession.shared.token ?? "")
//       ]
//
//       guard let url = urlComponents.url else {
//           self.alerMessage = "Invalid URL components"
//           return
//       }
//
//       var request = URLRequest(url: url)
//       request.httpMethod = "GET"
//
//       isLoading = true
//        alerMessage = nil
//
//       URLSession.shared.dataTask(with: request) { data, response, error in
//           DispatchQueue.main.async {
//               self.isLoading = false
//           }
//
//           if let error = error {
//               DispatchQueue.main.async {
//                   self.alerMessage = "Network error: \(error.localizedDescription)"
//                   self.showAlert = true
//               }
//               print("❌ API error:", error.localizedDescription)
//               return
//           }
//
//           guard let httpResponse = response as? HTTPURLResponse else {
//               DispatchQueue.main.async {
//                   self.alerMessage = "Invalid response from server"
//                   self.showAlert = true
//               }
//               print("❌ Invalid response object")
//               return
//           }
//
//           guard (200...299).contains(httpResponse.statusCode) else {
//               DispatchQueue.main.async {
//                   self.alerMessage = "Server error: \(httpResponse.statusCode)"
//               }
//               print("❌ Server returned status code: \(httpResponse.statusCode)")
//               if let data = data, let rawString = String(data: data, encoding: .utf8) {
//                   DispatchQueue.main.async {
//                       self.alerMessage = rawString
//                       self.showAlert = true
//                   }
//                   print("🔸 Server response body:\n\(rawString)")
//               }
//               return
//           }
//
//           guard let data = data else {
//               DispatchQueue.main.async {
//                   self.alerMessage = "No data received"
//                   self.showAlert = true
//               }
//               print("❌ No data returned by server")
//               return
//           }
//
//           do {
//               let decoder = JSONDecoder()
//               let userResponse = try decoder.decode(UserProfileResponse.self, from: data)
//               
//               DispatchQueue.main.async {
//                   self.profile = userResponse.data // ✅ This was missing!
//                   self.showAlert = false
//               }
//               
//               DispatchQueue.main.async {
//                   if let jsonString = String(data: data, encoding: .utf8) {
//                       print("🔍 success Raw JSON (for debugging):\n\(jsonString)")
//                   }
//               }
//           } catch {
//               DispatchQueue.main.async {
//                   self.alerMessage = "Failed to parse data"
//                   self.showAlert = true
//               }
//               print("❌ Decoding error:", error)
//               if let jsonString = String(data: data, encoding: .utf8) {
//                   print("🔍 failedRaw JSON (for debugging):\n\(jsonString)")
//               }
//           }
//       }.resume()
//   }
    
    func fetchProfile(token: String) {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.customerProfile) else {
            self.alerMessage = "Invalid URL"
            self.showAlert = true
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: token)
        ]

        guard let url = urlComponents.url else {
            self.alerMessage = "Invalid URL components"
            self.showAlert = true
            return
        }

        isLoading = true
        alerMessage = nil

        APIManager.shared.request(
            url: url,
            method: "GET",
            headers: ["Content-Type": "application/json"],
            responseType: UserProfileResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.profile = response.data
                    self?.showAlert = false
                    print("✅ Profile fetched successfully.")
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert = true
                    self?.alerMessage = error.localizedDescription
                }

                // Optional: Debug info
                switch error {
                case let APIError.decodingError(decodingError, rawData):
                    print("❌ Decoding error:", decodingError)
                    if let raw = String(data: rawData, encoding: .utf8) {
                        print("🔍 Raw JSON:\n\(raw)")
                        self?.alerMessage = raw
                    }
                case let APIError.serverError(message):
                    print("❌ Server error:", message)
                case let APIError.unknown(err):
                    print("❌ Unknown error:", err)
                default:
                    print("❌ General error:", error.localizedDescription)
                }
            }
        }
    }

}
