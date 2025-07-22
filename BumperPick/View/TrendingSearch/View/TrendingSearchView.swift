//
//  TrendingSearchView.swift
//  BumperPick
//
//  Created by tauseef hussain on 24/06/25.
//

import SwiftUI

struct TrendingSearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var trendingVM = TrendingSearchViewModel()
    @StateObject private var homeVM = HomeViewModel(isShowAdd: false)//HomeViewModel()
    @StateObject private var filterSortVM = FilterSortViewModel()

    @State private var showFilterSheet = false
    @State private var showSortSheet = false

    let distanceValueToDisplay = [
        1: "Upto 1Km", 3: "Upto 3Km", 5: "Upto 5Km", 10: "Upto 10Km", 11: "Beyond 10Km"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header with clear button
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }

                HStack {
                    TextField("Search for Reliance mart", text: $homeVM.searchText)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            // Do nothing special — searchText handles logic
                        }

                    if !homeVM.searchText.isEmpty {
                        Button(action: {
                            homeVM.searchText = ""
                            trendingVM.fetchTrendingSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)

            if homeVM.searchText.isEmpty {
                trendingList
            } else {
                filtersSection
                offersList
            }
        }
        .withLoader(homeVM.isLoading || trendingVM.isLoading)
        .onAppear {
            trendingVM.fetchTrendingSearch()
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(
                selectedDistance: $filterSortVM.appliedDistanceFilter,
                selectedCategories: $filterSortVM.appliedCategoryFilters,
                selectedVendors: $filterSortVM.appliedVendorFilters,
                categories: homeVM.categories
            )
        }
        .sheet(isPresented: $showSortSheet) {
            SortBySheetView(selectedSort: $filterSortVM.selectedSortOption)
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: showFilterSheet) { _, newValue in
            if !newValue { callSearchAPI() }
        }
        .onChange(of: filterSortVM.appliedDistanceFilter) { _, _ in
            callSearchAPI()
        }
        .onChange(of: filterSortVM.appliedCategoryFilters) { _, _ in
            callSearchAPI()
        }
        .onChange(of: filterSortVM.selectedSortOption) { _, _ in
            callSearchAPI()
        }
        .alert(isPresented: $homeVM.showAlert) {
            Alert(title: Text("Alert"), message: Text(homeVM.alertMessage ?? "Something went wrong"), dismissButton: .default(Text("OK")))
        }
        .navigationBarHidden(true)
    }

    private func callSearchAPI() {
        let sortBy = sortByValue(from: filterSortVM.selectedSortOption)
        homeVM.fetchHomeData(
            categoryId: Array(filterSortVM.appliedCategoryFilters),
            subcategoryId: nil,
            distanceFilter: filterSortVM.appliedDistanceFilter,
            sortBy: sortBy,
            searchText: homeVM.searchText, isShowAdd: false
        )
    }

    private var trendingList: some View {
        VStack(alignment: .leading) {
            Text("Trending searches")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(trendingVM.trendingSearch?.data ?? [], id: \.self) { keyword in
                    Button(action: {
                        homeVM.searchText = keyword
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.red)
                            Text(keyword)
                        }
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button { showFilterSheet = true } label: {
                    HStack {
                        if filterSortVM.totalActiveFilters > 0 {
                            ZStack {
                                Circle().fill(appThemeRedColor).frame(width: 18, height: 18)
                                Text("\(filterSortVM.totalActiveFilters)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }
                        Text("Filters")
                        Image(systemName: "slider.horizontal.3").rotationEffect(.degrees(270))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray))
                }

                if let distance = filterSortVM.appliedDistanceFilter,
                   let text = distanceValueToDisplay[distance] {
                    FilterChip(text: text) {
                        filterSortVM.appliedDistanceFilter = nil
                    }
                }

                ForEach(Array(filterSortVM.appliedCategoryFilters), id: \.self) { categoryId in
                    if let categoryName = homeVM.categories.first(where: { $0.id == categoryId })?.name {
                        FilterChip(text: categoryName) {
                            filterSortVM.appliedCategoryFilters.remove(categoryId)
                        }
                    }
                }

                ForEach(Array(filterSortVM.appliedVendorFilters), id: \.self) { vendor in
                    FilterChip(text: vendor) {
                        filterSortVM.appliedVendorFilters.remove(vendor)
                    }
                }

                Button {
                    showSortSheet = true
                } label: {
                    HStack {
                        Text("Sort by")
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray))
                }

                if filterSortVM.selectedSortOption != "Latest First (Default)" {
                    FilterChip(text: filterSortVM.selectedSortOption) {
                        filterSortVM.selectedSortOption = "Latest First (Default)"
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
    }

    private var offersList: some View {
        ScrollView {
            LazyVStack(spacing: -10) {
                ForEach(homeVM.offers, id: \.id) { offer in
                    HomeOfferCardView(offer: offer) {
                        homeVM.faverouiteTogelApi(offerId: "\(offer.id ?? 0)")
                    }
                }

                if homeVM.offers.isEmpty {
                    VStack(spacing: 8) {
                        Text("No offers found.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

