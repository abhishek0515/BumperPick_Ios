//
//  CartViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 12/06/25.
//


import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var isLoading = false
    @Published var alerMessage: String? = nil
    @Published var cartItem: [CartItem] = []
    @Published var showAlert = false

    
     func fetchCartOffers(customerId: Int, token: String) {
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.cartOfferApi) else {
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
                    self.alerMessage = rawString
                    print("🔸 Server response body:\n\(rawString)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.alerMessage = "No data received"
                }
                print("❌ No data returned by server")
                return
            }

            do {
                let decoder = JSONDecoder()
                let offerResponse = try decoder.decode(CartResponse.self, from: data)

                print("cart Offers: \(offerResponse.data.count)")
                DispatchQueue.main.async {
                    self.offers = offerResponse.data.map { $0.offer }
                    self.cartItem = offerResponse.data

                }
            } catch {
                DispatchQueue.main.async {
                    self.alerMessage = "Failed to parse data"
                    self.showAlert = true
                }
                print("❌ Decoding error:", error)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON (for debugging):\n\(jsonString)")
                }
            }
        }.resume()
    }
    
    func deleteCartOffer(cartId: Int, token: String) {
       let urlString = AppString.baseUrl + AppString.deleteCartOfferApi + "\(cartId)"

        print("finalDeleteURl :\(urlString)")
        guard var urlComponents = URLComponents(string: urlString) else {
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

               print("❌ Server returned status code: \(httpResponse.statusCode)")
               if let data = data, let rawString = String(data: data, encoding: .utf8) {
                   print("🔸 Server response body:\n\(rawString)")
                   DispatchQueue.main.async {
                       self.alerMessage = rawString
                       self.showAlert = true
                   }
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
               //success
               if let jsonString = String(data: data, encoding: .utf8) {
                   print("🔍 Raw JSON  success (for debugging):\n\(jsonString)")
               }
               
               let decoder = JSONDecoder()
               let cartDeleteResposne = try decoder.decode(CartDeleteResponse.self, from: data)

               print("cart Offers: \(cartDeleteResposne.data)")

               DispatchQueue.main.async {
                   // ✅ Remove from local list
                   self.cartItem.removeAll { $0.id == cartId }
                   self.alerMessage = cartDeleteResposne.message
                   self.showAlert = true
               }
               
           } catch {
               DispatchQueue.main.async {
                   self.alerMessage = "Failed to parse data"
                   self.showAlert = true
               }
               print("❌ Decoding error:", error)
               if let jsonString = String(data: data, encoding: .utf8) {
                   print("🔍 Raw JSON (for debugging):\n\(jsonString)")
               }
           }
       }.resume()
   }
}
