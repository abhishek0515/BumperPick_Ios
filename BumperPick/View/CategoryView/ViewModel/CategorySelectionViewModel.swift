//
//  CategorySelectionViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/06/25.
//


import Foundation

class CategorySelectionViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchCategories() {
        let urlString = AppString.categoriesApi
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                //from here
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid response from server."
                    }
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    DispatchQueue.main.async {
                        if let  rawString = String(data: data, encoding: .utf8) {
                                if let data = rawString.data(using: .utf8) {
                                    do {
                                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                           let message = json["message"] as? String {
    //                                        self?.alertMessage = message
                                            self.errorMessage = rawString
                                            print("rawString: :\(rawString)")
                                    }

                                    } catch {
                                        print("Failed to parse JSON: \(error)")
                                    }
                                }
                            }
                        
                    }
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(CategoryResponse.self, from: data)
                    self.categories = decoded.data
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("🔍 success JSON (for debugging):\n\(jsonString)")
                    }
                } catch {
                    self.errorMessage = "Failed to decode: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
