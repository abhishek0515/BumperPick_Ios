//
//  SearchView.swift
//  BumperPick
//
//  Created by tauseef hussain on 14/07/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFilterSheet = false
    @State private var showSortSheet = false
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var filterSortVM = FilterSortViewModel() // shared if needed
    
    let initialSearchText: String // Add this parameter

    let distanceValueToDisplay = [
        1: "Upto 1Km", 3: "Upto 3Km", 5: "Upto 5Km", 10: "Upto 10Km", 11: "Beyond 10Km"
    ]
    
    // Add initializer to accept search text
    init(initialSearchText: String = "") {
        self.initialSearchText = initialSearchText
    }
    
    var body: some View {
        VStack(spacing: 20) {
            CustomHeaderViewNew(
                title: "Search",
                showBackButton: true,
                backAction: { dismiss() },
                searchText: $viewModel.searchText, searchPlaceholder: "Search Item.."
            )
            .padding(.top, -40)
            addFilterSort
            bumperPickChoice
            showMyOffer
            //till
        }
        .withLoader(viewModel.isLoading)
        .onAppear(){
            // Set the initial search text when view appears
            if !initialSearchText.isEmpty {
                viewModel.searchText = initialSearchText
            }
            self.callSearchAPI()
        }
        .onChange(of: showFilterSheet) { oldValue, newValue in
            if newValue == false {
                self.callSearchAPI()
            }
        }
        .onChange(of: showFilterSheet) { oldValue, newValue in
            if newValue == false {
                self.callSearchAPI()
            }
        }
        .onChange(of: filterSortVM.appliedDistanceFilter) { _, _ in
            self.callSearchAPI()
        }
        .onChange(of: filterSortVM.appliedCategoryFilters) { _, _ in
            self.callSearchAPI()
        }
        .onChange(of: filterSortVM.selectedSortOption) { _, _ in
            self.callSearchAPI()
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(
                selectedDistance: $filterSortVM.appliedDistanceFilter,
                selectedCategories: $filterSortVM.appliedCategoryFilters,
                selectedVendors: $filterSortVM.appliedVendorFilters,
                categories: viewModel.categories // or pass separately
            )
        }
        .sheet(isPresented: $showSortSheet) {
            SortBySheetView(selectedSort: $filterSortVM.selectedSortOption)
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Alert"), message: Text(viewModel.alertMessage ?? "Something went wrong"), dismissButton: .default(Text("OK")))
        }
        .navigationBarHidden(true)
    }
    
    private func callSearchAPI() {
        let sortBy = sortByValue(from: filterSortVM.selectedSortOption)
        viewModel.fetchHomeData(categoryId: Array(filterSortVM.appliedCategoryFilters), subcategoryId: nil, distanceFilter: filterSortVM.appliedDistanceFilter, sortBy: sortBy, searchText: viewModel.searchText, isShowAdd: false)
    }
    
    private var bumperPickChoice: some View {
        HStack {
            Image("leftArrow")
                .resizable()
                .frame(width: 10, height: 10)
                .aspectRatio(contentMode: .fit)
            
            Text("BumperPick Choice")
                .font(.caption)
                .foregroundColor(.gray)
            
            Image("rightArrow")
                .resizable()
                .frame(width: 10, height: 10)
                .aspectRatio(contentMode: .fit)
        }
    }
    
    private var addFilterSort: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Filter button
                Button(action: {
                    showFilterSheet = true
                }) {
                    HStack {
                        if filterSortVM.totalActiveFilters > 0 {
                            ZStack {
                                Circle()
                                    .fill(appThemeRedColor)
                                    .frame(width: 18, height: 18)
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

                // Applied filters
                if let distance = filterSortVM.appliedDistanceFilter,
                   let text = distanceValueToDisplay[distance] {
                    FilterChip(text: text) {
                        filterSortVM.appliedDistanceFilter = nil
                    }
                }

                ForEach(Array(filterSortVM.appliedCategoryFilters), id: \.self) { categoryId in
                    if let categoryName = viewModel.categories.first(where: { $0.id == categoryId })?.name {
                        FilterChip(text: categoryName) {
                            filterSortVM.appliedCategoryFilters.remove(categoryId)
                          //  appliedCategoryFilters.remove(categoryId)
                        }
                    }
                }


                ForEach(Array(filterSortVM.appliedVendorFilters), id: \.self) { vendor in
                    FilterChip(text: vendor) {
                        filterSortVM.appliedVendorFilters.remove(vendor)
                    }
                }

                // Sort button
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

                // Sort chip
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
    
    private var showMyOffer: some View {
        ScrollView {
            // Offers List
            LazyVStack(spacing: -10) {
                ForEach(viewModel.offers, id: \.id) { offer in
                    HomeOfferCardView(offer: offer, favrouiteOffer: {
                        print("favorite tapped :\(offer.id ?? 0) \(offer.title ?? "")")
                        viewModel.faverouiteTogelApi(offerId: "\( offer.id ?? 0)")
                    })
                        .onScrollVisibilityChange(
                            coordinateSpace: "OfferScroll",
                            visibleHeight: 300
                        ) { isVisible in
                            // handle visibility if needed
                        }
                }
                
                if viewModel.offers.isEmpty {
                    VStack(spacing: 8) {
                        Text("No offers found.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                }
            }
            .coordinateSpace(name: "OfferScroll")
            .padding(.bottom, 20) // extra space to avoid clipping
        }
    }
}

//#Preview {
//    SearchView()
//}

