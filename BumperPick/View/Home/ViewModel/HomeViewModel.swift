//
//  HomeViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 10/06/25.
//
import SwiftUI
import Combine


class HomeViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var didFetchData = false
    @Published var showAlert = false
    @Published var searchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let isShowAdd: Bool
    
      init(isShowAdd: Bool = true) {
          self.isShowAdd = isShowAdd
          
          // Debounced search handling
          $searchText
              .dropFirst()
              .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
              .removeDuplicates()
              .sink { [weak self] text in
                  self?.fetchHomeData(
                      categoryId: Array(FilterSortViewModel.shared.appliedCategoryFilters),
                      subcategoryId: nil,
                      distanceFilter: FilterSortViewModel.shared.appliedDistanceFilter,
                      sortBy: "",
                      searchText: text,
                      isShowAdd: self?.isShowAdd ?? true
                  )
              }
              .store(in: &cancellables)
      }
    
    
    func fetchHomeData(categoryId: [Int], subcategoryId: Int?, distanceFilter: Int?, sortBy: String?, searchText: String?, isShowAdd: Bool) {
        print("categoryID::: \(categoryId)")
        print("subcatcategoryID: \(subcategoryId ?? 0)")

        didFetchData = true
        let urlString = AppString.baseUrl + AppString.OfferCustomerApi
        guard let url = URL(string: urlString) else {
            self.alertMessage = "Invalid URL"
            return
        }

        // Build request body with nil-safe values
        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "category_id":  categoryId,
            "subcategory_id": subcategoryId ?? "",
            "distance_filter": distanceFilter ?? 0,
            "sort_by": sortBy ?? "",
            "search": searchText ?? ""
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            self.alertMessage = "Failed to encode body"
            return
        }

        isLoading = true
        alertMessage = nil

        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: HomeDataResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
               // self.offers = response.offers
                if isShowAdd {
                    self.offers = response.offers
                } else {
                    self.offers = response.offers.filter { $0.isAds == false }
                }
                self.categories = response.categories
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                print("failedResponseHome")

                switch error {
                case let APIError.decodingError(decodingError, rawData):
                    print("❌ Decoding error: \(decodingError)")
                    if let raw = String(data: rawData, encoding: .utf8) {
                        print("🔍 Raw JSON: \(raw)")
                    }
                case let APIError.serverError(message):
                    print("❌ Server error: \(message)")
                case let APIError.unknown(err):
                    print("❌ Unknown error: \(err)")
                default:
                    print("❌ Error:", error.localizedDescription)
                }
            }
        }
    }
    
    func faverouiteTogelApi(offerId: String) {
        
        let urlString = AppString.baseUrl + AppString.favrouiteApi
        guard let url = URL(string: urlString) else {
            self.alertMessage = "Invalid URL"
            return
        }

        // Build request body with nil-safe values
        let params: [String: Any] = [
            "token": CustomerSession.shared.token ?? "",
            "promotion_id": offerId
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            self.alertMessage = "Failed to encode body"
            return
        }

        isLoading = true
        alertMessage = nil

        APIManager.shared.request(
            url: url,
            method: "POST",
            body: body,
            headers: ["Content-Type": "application/json"],
            responseType: FavouriteResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                self.handleFavouriteResponse(response)
                showAlert = true
                self.alertMessage = response.message
            case .failure(let error):
                showAlert = true
                self.alertMessage = error.localizedDescription
                print("failedResponseHome")

                switch error {
                case let APIError.decodingError(decodingError, rawData):
                    print("❌ Decoding error: \(decodingError)")
                    if let raw = String(data: rawData, encoding: .utf8) {
                        self.alertMessage = raw
                        print("🔍 Raw JSON: \(raw)")
                    }
                case let APIError.serverError(message):
                    print("❌ Server error: \(message)")
                case let APIError.unknown(err):
                    print("❌ Unknown error: \(err)")
                default:
                    print("❌ Error:", error.localizedDescription)
                }
            }
        }
    }

    func handleFavouriteResponse(_ response: FavouriteResponse) {
        if let index = offers.firstIndex(where: { $0.id == response.promotionID }) {
            offers[index].isFavourited = (response.status == "added")
        }
    }
    
}


//class HomeViewModel: ObservableObject {
//    @Published var offers: [Offer] = []
//    @Published var categories: [Category] = []
//    @Published var isLoading = false
//    @Published var alertMessage: String?
//    @Published var didFetchData = false
//    @Published var showAlert = false
//    @Published var searchText: String = ""
//    private var cancellables = Set<AnyCancellable>()
//  //  var filterSortVM: FilterSortViewModel = FilterSortViewModel()
//    
//    init() {
//        $searchText
//            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { [weak self] text in
//                self?.fetchHomeData(
//                    categoryId: Array(FilterSortViewModel.shared.appliedCategoryFilters),
//                    subcategoryId: nil,
//                    distanceFilter: FilterSortViewModel.shared.appliedDistanceFilter,
//                    sortBy: "",
//                    searchText: text
//                )
//            }
//            .store(in: &cancellables)
//    }
//    
//    func fetchHomeData(categoryId: [Int], subcategoryId: Int?, distanceFilter: Int?, sortBy: String?, searchText: String?) {
//        didFetchData = true
//        let urlString = AppString.baseUrl + AppString.OfferCustomerApi
//        guard let url = URL(string: urlString) else {
//            self.alertMessage = "Invalid URL"
//            return
//        }
//
//        // Build request body with nil-safe values
//        let params: [String: Any] = [
//            "token": CustomerSession.shared.token ?? "",
//            "category_id":  categoryId,
//            "subcategory_id": subcategoryId ?? "",
//            "distance_filter": distanceFilter ?? 0,
//            "sort_by": sortBy ?? "",
//            "search": searchText ?? ""
//        ]
//
//        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
//            self.alertMessage = "Failed to encode body"
//            return
//        }
//
//        isLoading = true
//        alertMessage = nil
//
//        APIManager.shared.request(
//            url: url,
//            method: "POST",
//            body: body,
//            headers: ["Content-Type": "application/json"],
//            responseType: HomeDataResponse.self
//        ) { [weak self] result in
//            guard let self = self else { return }
//            self.isLoading = false
//
//            switch result {
//            case .success(let response):
//                self.offers = response.offers
//                self.categories = response.categories
//            case .failure(let error):
//                self.alertMessage = error.localizedDescription
//                print("failedResponseHome")
//
//                switch error {
//                case let APIError.decodingError(decodingError, rawData):
//                    print("❌ Decoding error: \(decodingError)")
//                    if let raw = String(data: rawData, encoding: .utf8) {
//                        print("🔍 Raw JSON: \(raw)")
//                    }
//                case let APIError.serverError(message):
//                    print("❌ Server error: \(message)")
//                case let APIError.unknown(err):
//                    print("❌ Unknown error: \(err)")
//                default:
//                    print("❌ Error:", error.localizedDescription)
//                }
//            }
//        }
//    }
//    
//    func faverouiteTogelApi(offerId: String) {
//        
//        let urlString = AppString.baseUrl + AppString.favrouiteApi
//        guard let url = URL(string: urlString) else {
//            self.alertMessage = "Invalid URL"
//            return
//        }
//
//        // Build request body with nil-safe values
//        let params: [String: Any] = [
//            "token": CustomerSession.shared.token ?? "",
//            "promotion_id": offerId
//        ]
//
//        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
//            self.alertMessage = "Failed to encode body"
//            return
//        }
//
//        isLoading = true
//        alertMessage = nil
//
//        APIManager.shared.request(
//            url: url,
//            method: "POST",
//            body: body,
//            headers: ["Content-Type": "application/json"],
//            responseType: FavouriteResponse.self
//        ) { [weak self] result in
//            guard let self = self else { return }
//            self.isLoading = false
//
//            switch result {
//            case .success(let response):
//                self.handleFavouriteResponse(response)
//                showAlert = true
//                self.alertMessage = response.message
//            case .failure(let error):
//                showAlert = true
//                self.alertMessage = error.localizedDescription
//                print("failedResponseHome")
//
//                switch error {
//                case let APIError.decodingError(decodingError, rawData):
//                    print("❌ Decoding error: \(decodingError)")
//                    if let raw = String(data: rawData, encoding: .utf8) {
//                        self.alertMessage = raw
//                        print("🔍 Raw JSON: \(raw)")
//                    }
//                case let APIError.serverError(message):
//                    print("❌ Server error: \(message)")
//                case let APIError.unknown(err):
//                    print("❌ Unknown error: \(err)")
//                default:
//                    print("❌ Error:", error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    func handleFavouriteResponse(_ response: FavouriteResponse) {
//        if let index = offers.firstIndex(where: { $0.id == response.promotionID }) {
//            offers[index].isFavourited = (response.status == "added")
//        }
//    }
//    
//}
