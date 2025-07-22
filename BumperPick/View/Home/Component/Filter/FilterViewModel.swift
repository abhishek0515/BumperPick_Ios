//
//  FilterViewModel.swift
//  BumperPick
//
//  Created by tauseef hussain on 13/07/25.
//
import Foundation

class FilterViewModel: ObservableObject {
    @Published var selectedTab: FilterTab = .distance
    
    @Published var distanceOptions: [FilterOption] = [
        FilterOption(name: "Upto 1Km", isSelected: false),
        FilterOption(name: "Upto 3Km", isSelected: true),
        FilterOption(name: "Upto 5Km", isSelected: false),
        FilterOption(name: "Upto 10Km", isSelected: false),
        FilterOption(name: "Beyond 10Km", isSelected: false)
    ]
    
    @Published var categoryOptions: [FilterOption] = [
        FilterOption(name: "Hotels", isSelected: true),
        FilterOption(name: "Fashions", isSelected: false),
        FilterOption(name: "Tech and Gadgets", isSelected: false),
        FilterOption(name: "Fine Dining", isSelected: false),
        FilterOption(name: "Cafes", isSelected: false)
    ]
    
    @Published var bumperPickOptions: [FilterOption] = [
        FilterOption(name: "Vendors shop name 1", isSelected: false),
        FilterOption(name: "Vendors shop name 2", isSelected: true),
        FilterOption(name: "Vendors shop name 3", isSelected: false),
        FilterOption(name: "Vendors shop name 4", isSelected: false),
        FilterOption(name: "Vendors shop name 5", isSelected: false)
    ]
    
    func clearAll() {
        distanceOptions.indices.forEach { distanceOptions[$0].isSelected = false }
        categoryOptions.indices.forEach { categoryOptions[$0].isSelected = false }
        bumperPickOptions.indices.forEach { bumperPickOptions[$0].isSelected = false }
    }
    
    var selectedFilters: [String] {
        distanceOptions.filter(\.isSelected).map(\.name) +
        categoryOptions.filter(\.isSelected).map(\.name) +
        bumperPickOptions.filter(\.isSelected).map(\.name)
    }
}
