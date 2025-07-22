//
//  FilterSheetView.swift
//  BumperPick
//
//  Created by tauseef hussain on 13/07/25.
//
import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedDistance: Int?
    @Binding var selectedCategories: Set<Int> // Store category IDs now
    @Binding var selectedVendors: Set<String>
    let categories: [Category]
    enum FilterTab: String, CaseIterable {
        case distance = "Distance"
        case categories = "Categories"
    }
    @State private var selectedTab: FilterTab = .distance
    @State private var tempDistance: Int?
    @State private var tempCategories: Set<Int> = []
      @State private var tempVendors: Set<String> = []
    private let distanceDisplayToValue: [String: Int] = [
        "Upto 1Km": 1,
        "Upto 3Km": 3,
        "Upto 5Km": 5,
        "Upto 10Km": 10,
        "Beyond 10Km": 11
    ]

    private var distanceValueToDisplay: [Int: String] {
        Dictionary(uniqueKeysWithValues: distanceDisplayToValue.map { ($1, $0) })
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Filters")
                .font(.headline)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)

            Divider()

            HStack(spacing: 0) {
                // Left Tab Bar
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(FilterTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(selectedTab == tab ? appThemeRedColor : Color.clear)
                                    .frame(width: 4, height: 50)
                                // Tab label
                                Text(tab.rawValue)
                                    .foregroundColor(selectedTab == tab ? appThemeRedColor : .black)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(
                                        selectedTab == tab ? appThemeRedColor.opacity(0.1) : Color.clear
                                    )
                            }
                        }
                    }
                    Spacer()
                }
                .frame(width: 130)
                .background(Color.white)
                
                Divider()
                VStack(alignment: .leading) {
                    Text("SELECT BY")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                        .padding()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            switch selectedTab {
                            case .distance:
                                ForEach(distanceDisplayToValue.sorted(by: { $0.value < $1.value }), id: \.key) { (display, value) in
                                    HStack {
                                        Image(systemName: tempDistance == value ? "largecircle.fill.circle" : "circle")
                                            .foregroundColor(appThemeRedColor)
                                        Text(display)
                                            .bold(tempDistance == value)
                                    }
                                    .padding(.leading)
                                    .onTapGesture {
                                        tempDistance = value
                                    }
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                }
                            case .categories:
                                let allCategoryIDs = Set(categories.map { $0.id })
                                let allSelected = tempCategories == allCategoryIDs

                                ForEach(["All"] + categories.map { $0.name }, id: \.self) { categoryName in
                                    let isAll = categoryName == "All"
                                    let isSelected: Bool = {
                                        if isAll {
                                            return allSelected
                                        } else if let cat = categories.first(where: { $0.name == categoryName }) {
                                            return tempCategories.contains(cat.id)
                                        }
                                        return false
                                    }()

                                    HStack {
                                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                            .foregroundColor(appThemeRedColor)
                                        Text(categoryName)
                                            .foregroundColor(.black)
                                            .bold(isSelected)
                                    }
                                    .padding(.leading)
                                    .onTapGesture {
                                        if isAll {
                                            if allSelected {
                                                tempCategories.removeAll()
                                            } else {
                                                tempCategories = allCategoryIDs
                                            }
                                        } else if let cat = categories.first(where: { $0.name == categoryName }) {
                                            if tempCategories.contains(cat.id) {
                                                tempCategories.remove(cat.id)
                                            } else {
                                                tempCategories.insert(cat.id)
                                            }
                                        }
                                    }

                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Divider()
            HStack {
                Spacer()
                // Clear All Button
                Button(action: {
                    tempDistance = nil
                      tempCategories.removeAll()
                      tempVendors.removeAll()
                      selectedDistance = tempDistance
                      selectedCategories = tempCategories
                      selectedVendors = tempVendors
                      dismiss()
                }) {
                    Text("Clear all")
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                Spacer(minLength: 16)
                // Apply Filters Button
                Button(action: {
                    selectedDistance = tempDistance
                      selectedCategories = tempCategories
                      selectedVendors = tempVendors
                      dismiss()
                }) {
                    Text("Apply Filters")
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(appThemeRedColor)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.4), radius: 2, x: 0, y: 2)
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .onAppear {
            tempDistance = selectedDistance
            tempCategories = selectedCategories
            tempVendors = selectedVendors
        }        .background(Color.white)
        .cornerRadius(16)
        .padding(.top)
    }
}


//
//#Preview {
//    FilterSheetView()
//}

