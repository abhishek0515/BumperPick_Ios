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
        guard let url = URL(string: AppString.categoriesApi) else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        APIManager.shared.request(
            url: url,
            method: "GET",
            headers: ["Content-Type": "application/json"],
            responseType: CategoryResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                self.categories = response.data
                print("✅ Categories fetched:", response.data.count)

            case .failure(let error):
                self.errorMessage = error.localizedDescription

                switch error {
                case let APIError.decodingError(decodingError, rawData):
                    print("❌ Decoding error:", decodingError)
                    if let raw = String(data: rawData, encoding: .utf8) {
                        print("🔍 Raw JSON:\n\(raw)")
                        self.errorMessage = raw
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
