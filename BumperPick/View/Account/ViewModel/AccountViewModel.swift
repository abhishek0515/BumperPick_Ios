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
    
    func fetchProfile(token: String) {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.customerProfile) else {
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

       var request = URLRequest(url: url)
       request.httpMethod = "GET"

       isLoading = true
        alerMessage = nil

       URLSession.shared.dataTask(with: request) { data, response, error in
           DispatchQueue.main.async {
               self.isLoading = false
           }

           if let error = error {
               DispatchQueue.main.async {
                   self.alerMessage = "Network error: \(error.localizedDescription)"
                   self.showAlert = true
               }
               print("❌ API error:", error.localizedDescription)
               return
           }

           guard let httpResponse = response as? HTTPURLResponse else {
               DispatchQueue.main.async {
                   self.alerMessage = "Invalid response from server"
                   self.showAlert = true
               }
               print("❌ Invalid response object")
               return
           }

           guard (200...299).contains(httpResponse.statusCode) else {
               DispatchQueue.main.async {
                   self.alerMessage = "Server error: \(httpResponse.statusCode)"
               }
               print("❌ Server returned status code: \(httpResponse.statusCode)")
               if let data = data, let rawString = String(data: data, encoding: .utf8) {
                   DispatchQueue.main.async {
                       self.alerMessage = rawString
                       self.showAlert = true
                   }
                   print("🔸 Server response body:\n\(rawString)")
               }
               return
           }

           guard let data = data else {
               DispatchQueue.main.async {
                   self.alerMessage = "No data received"
                   self.showAlert = true
               }
               print("❌ No data returned by server")
               return
           }

           do {
               let decoder = JSONDecoder()
               let userResponse = try decoder.decode(UserProfileResponse.self, from: data)
               
               DispatchQueue.main.async {
                   self.profile = userResponse.data // ✅ This was missing!
                   self.showAlert = false
               }
               
               DispatchQueue.main.async {
                   if let jsonString = String(data: data, encoding: .utf8) {
                       print("🔍 success Raw JSON (for debugging):\n\(jsonString)")
                   }
               }
           } catch {
               DispatchQueue.main.async {
                   self.alerMessage = "Failed to parse data"
                   self.showAlert = true
               }
               print("❌ Decoding error:", error)
               if let jsonString = String(data: data, encoding: .utf8) {
                   print("🔍 failedRaw JSON (for debugging):\n\(jsonString)")
               }
           }
       }.resume()
   }
}
