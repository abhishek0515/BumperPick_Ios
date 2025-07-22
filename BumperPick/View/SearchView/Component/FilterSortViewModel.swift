//
//  FilterSortViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 14/07/25.
//
import Foundation

class FilterSortViewModel: ObservableObject {
    @Published var appliedDistanceFilter: Int? = nil
    @Published var appliedCategoryFilters: Set<Int> = []
    @Published var appliedVendorFilters: Set<String> = []
    @Published var selectedSortOption: String = "Latest First (Default)"
    static let shared = FilterSortViewModel() // 👈 Add this

    var totalActiveFilters: Int {
        var count = 0
        if appliedDistanceFilter != nil { count += 1 }
        count += appliedCategoryFilters.count
        count += appliedVendorFilters.count
        return count
    }
}
