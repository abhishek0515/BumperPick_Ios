//
//  HomeViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 10/06/25.
//
import SwiftUI


class HomeViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didFetchData = false

    func fetchHomeData() {
        didFetchData = true
        guard var urlComponents = URLComponents(string: AppString.baseUrl + AppString.OfferCustomerApi) else {
            self.errorMessage = "Invalid URL"
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: CustomerSession.shared.token ?? "")
        ]

        guard let url = urlComponents.url else {
            self.errorMessage = "Invalid URL components"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                print("❌ API error:", error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from server"
                }
                print("❌ Invalid response object")
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                }
                print("❌ Server returned status code: \(httpResponse.statusCode)")
                if let data = data, let rawString = String(data: data, encoding: .utf8) {
                    print("🔸 Server response body:\n\(rawString)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                print("❌ No data returned by server")
                return
            }

            do {
                let decoder = JSONDecoder()
                let offerResponse = try decoder.decode(HomeDataResponse.self, from: data)

                print("✅ Offers: \(offerResponse.offers.count), Categories: \(offerResponse.categories.count)")
                print("offerNew test")
                DispatchQueue.main.async {
                    self.offers = offerResponse.offers.filter { !$0.expire! }
                    self.categories = offerResponse.categories
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse data"
                }
                print("❌ Decoding error:", error)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON (for debugging):\n\(jsonString)")
                }
            }
        }.resume()
    }
}
