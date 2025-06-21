//
//  QRCodePopupViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 12/06/25.
//

import SwiftUI

class QRCodePopupViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var alertMessage = ""
    @Published var success = false



    func saveToCart(customerId: Int, offerId: Int, token: String, completion: @escaping (Result<SaveToCartResponse, Error>) -> Void) {
        isLoading = true

        let urlString = AppString.baseUrl + AppString.saveToCartApi
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "customer_id": customerId,
            "offer_id": offerId,
            "token": token
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted) {
            request.httpBody = jsonData
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                // ✅ Pretty-print JSON for debug
                if let jsonString = String(data: data, encoding: .utf8) {
                    self.alertMessage = jsonString
                    print("📨 Raw JSON Response:\n\(jsonString)")
                    
                }
                /// from heer
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        self.alertMessage = "Invalid response from server."
                    }
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    if let rawString = String(data: data, encoding: .utf8),
//                    if let rawString = String(data: data ?? Data(), encoding: .utf8),
                       let jsonData = rawString.data(using: .utf8) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                               let message = json["message"] as? String {
                                
                                let code = json["code"] as? Int
                                self.alertMessage = (code != 200) ? rawString : message
                                self.success = (code ?? 0) == 200
                                print("success: :\(self.success)")
                            }
                        } catch {
                            print("⚠️ Failed to parse error JSON: \(error)")
                        }
                    }
                 
                }
                
                //till here

                do {
                 //   let decoded = try JSONDecoder().decode(SaveToCartResponse.self, from: data)
                    let decoder = JSONDecoder()
                     decoder.keyDecodingStrategy = .convertFromSnakeCase // ⬅️ Add this
                     let decoded = try decoder.decode(SaveToCartResponse.self, from: data)
                    self.alertMessage = decoded.message
                    print("✅ Decoded Model:\n\(decoded)")
                    completion(.success(decoded))
                } catch {
                    print("⚠️ JSON Decode Error:\n\(error.localizedDescription)")
                    // Extra debug info
//                    if let data = data, let rawString = String(data: data, encoding: .utf8) {
//                        self.alertMessage = rawString
//                        print("🔸 Server response body:\n\(rawString)")
//                    }
                    completion(.failure(error))
                }
            }
        }.resume()
    }


}
