//
//  HomeView.swift
//  BumperPick
//
//  Created by tauseef hussain on 09/06/25.
//

import SwiftUI

struct HomeView: View {
    @State private var currentIndex = 0
    @State private var campaignCartCurrentIndex = 0
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText: String = ""
    @StateObject private var locationManager = LocationManager()
    @State private var showPermissionPopup = false
    @EnvironmentObject var customerSession: CustomerSession
    var categoryID: Int?
    var subCategoryID: Int?
    @Environment(\.dismiss) private var dismiss
    @State private var showTrendingSearch = false
    @State private var showFilterSheet = false
    @State private var showSortSheet = false
    @StateObject private var filterSortVM = FilterSortViewModel() // shared if needed
    let distanceValueToDisplay = [
        1: "Upto 1Km", 3: "Upto 3Km", 5: "Upto 5Km", 10: "Upto 10Km", 11: "Beyond 10Km"
    ]
    private var exploreCampaignCardArr: [ExploreCampaignCard] {
        [
            ExploreCampaignCard(title: "Explore exciting campaigns near you", imageName: "Speaker", backgroundColor: Color(red: 1, green: 0.9, blue: 0.9), borderColor: .red),
            ExploreCampaignCard(title: "Next big win just a scratch away!", imageName: "scratchCard", backgroundColor: Color(red: 0.922, green: 0.953, blue: 0.976), borderColor: .blue)
        ]
    }
    
    var body: some View {
        if customerSession.isSessionLoaded {
            if let _ = customerSession.token {
                ScrollView {
                    VStack(spacing: 16) {
                        if categoryID == nil && subCategoryID == nil {
                            HomeHeaderSection(
                                categories: viewModel.categories,
                                searchText: $searchText,
                                onSearchTapped: {
                                    if !showTrendingSearch {
                                        showTrendingSearch = true
                                        searchText = ""
                                    }
                                }
                            )
                            exploreCampaignsCard()
                            trendingOffersCarousel
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // 1. Filters Button with Badge
                                    Button(action: {
                                        showFilterSheet = true
                                    }) {
                                        HStack(spacing: 6) {
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
                                                .foregroundColor(.black)
                                            Image(systemName: "slider.horizontal.3")
                                                .foregroundColor(.black)
                                                .rotationEffect(.degrees(270))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                    }
                                    if let distance = filterSortVM.appliedDistanceFilter,
                                       let distanceText = distanceValueToDisplay[distance] {
                                        FilterChip(text: distanceText) {
                                            filterSortVM.appliedDistanceFilter = nil
                                        }
                                    }

                                    ForEach(Array(filterSortVM.appliedCategoryFilters), id: \.self) { categoryId in
                                        if let categoryName = viewModel.categories.first(where: { $0.id == categoryId })?.name {
                                            FilterChip(text: categoryName) {
                                                filterSortVM.appliedCategoryFilters.remove(categoryId)
                                            }
                                        }
                                    }
                                    Button(action: {
                                        showSortSheet = true
                                    }) {
                                        HStack {
                                            Text("Sort by")
                                                .foregroundColor(.black)
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.black)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                    }

                                    // 4. Selected Sort Chip (if changed)
                                    if filterSortVM.selectedSortOption != "Latest First (Default)" {
                                        FilterChip(text: filterSortVM.selectedSortOption) {
                                            filterSortVM.selectedSortOption = "Latest First (Default)"
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
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
                        } else {
                            CustomHeaderViewNew(
                                title: "Offers",
                                showBackButton: true,
                                backAction: { dismiss() },
                                searchText: $searchText, searchPlaceholder: "Search offer"    // ✅ This will now work
                            )
                        }
                        // Offers List
                        LazyVStack(spacing: -10) {
                            let filteredOffers = viewModel.offers.filter {
                                searchText.isEmpty ||
                                ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                                ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
                            }
                            
                            ForEach(filteredOffers, id: \.id) { offer in
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
                            
                            if filteredOffers.isEmpty {
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
                    .withLoader(viewModel.isLoading)
                    .navigationDestination(isPresented: $showTrendingSearch) {
                       // TrendingSearchView(searchText: $searchText)
                        TrendingSearchView()
                    }
                }
                .background(Color(.systemGroupedBackground))
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    if !viewModel.didFetchData {
                        var idArray: [Int] = []
                        if !filterSortVM.appliedCategoryFilters.isEmpty {
                            idArray = Array(filterSortVM.appliedCategoryFilters)
                        } else if let singleCategoryID = categoryID {
                            idArray = [singleCategoryID] // Wrap the single value into an array
                        }
                        let sortBy = sortByValue(from: filterSortVM.selectedSortOption)
                        viewModel.fetchHomeData(categoryId: idArray, subcategoryId: subCategoryID, distanceFilter: filterSortVM.appliedDistanceFilter, sortBy: sortBy, searchText: "", isShowAdd: true)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        locationManager.requestPermission()
                    }
                }
                .onChange(of: showFilterSheet) { oldValue, newValue in
                    if newValue == false {
                        // Sheet was just dismissed — apply filters now
                        var idArray: [Int] = []
                        if !filterSortVM.appliedCategoryFilters.isEmpty {
                            idArray = Array(filterSortVM.appliedCategoryFilters)
                        } else if let singleCategoryID = categoryID {
                            idArray = [singleCategoryID]
                        }
                        self.callHomeApi(categoryIDArr: idArray)
                    }
                }
                .onChange(of: showSortSheet) { oldValue, newValue in
                    if newValue == false {
                        var idArray: [Int] = []
                        if !filterSortVM.appliedCategoryFilters.isEmpty {
                            idArray = Array(filterSortVM.appliedCategoryFilters)
                        } else if let singleCategoryID = categoryID {
                            idArray = [singleCategoryID]
                        }
                        self.callHomeApi(categoryIDArr: idArray)
                    }
                }
                .onChange(of: filterSortVM.appliedDistanceFilter) { _, _ in
                    self.callHomeApi(categoryIDArr: Array(filterSortVM.appliedCategoryFilters))
                }
                .onChange(of: filterSortVM.appliedCategoryFilters) { _, _ in
                    self.callHomeApi(categoryIDArr: Array(filterSortVM.appliedCategoryFilters))
                }
                .onChange(of: filterSortVM.selectedSortOption) { _, _ in
                    self.callHomeApi(categoryIDArr: Array(filterSortVM.appliedCategoryFilters))
                }
                .withLocationPermissionPopup(locationManager: locationManager, isPresented: $showPermissionPopup)
                .navigationBarHidden(true)
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text("Home View"), message: Text(viewModel.alertMessage ?? "Something went wrong"), dismissButton: .default(Text("OK")))
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

            }
        }
    }
    
    func callHomeApi(categoryIDArr: [Int])  {
        let sortBy = sortByValue(from: filterSortVM.selectedSortOption)
        viewModel.fetchHomeData(
            categoryId: categoryIDArr,
            subcategoryId: subCategoryID,
            distanceFilter: filterSortVM.appliedDistanceFilter,
            sortBy: sortBy, searchText: "", isShowAdd: true
        )

    }
    
    func exploreCampaignsCard() -> some View {
        VStack(spacing: 10) {
            TabView(selection: $campaignCartCurrentIndex) {
                ForEach(Array(exploreCampaignCardArr.enumerated()), id: \.element.id) { index, card in
                    NavigationLink(destination: CampaignView()) {
                        HStack {
                            Image(card.imageName)
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text(card.title)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(card.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(card.borderColor, lineWidth: 0.5)
                        )                        .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 80) // Adjust based on content
            
            // Pagination Dots
            HStack(spacing: 6) {
                ForEach(0..<exploreCampaignCardArr.count, id: \.self) { index in
                    Circle()
                        .fill(index == campaignCartCurrentIndex ? Color.blue : Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, -10)
        }
    }
    
    var trendingOffersCarousel: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image("leftArrow")
                    .resizable()
                    .frame(width: 10, height: 10)
                
                Text("TRENDING OFFERS")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                
                Image("rightArrow")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            TabView(selection: $currentIndex) {
                ForEach(0..<3) { index in
                    Image("TrendingOffer")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .tag(index)
                }
            }
            .frame(height: 230)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .padding(.horizontal, 10)
            .padding(.top, -5)
            
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, -10)
        }
    }
}

struct FilterChip: View {
    var text: String
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.red.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red, lineWidth: 1)
        )
        .cornerRadius(20)
    }
}


//#Preview {
//    HomeView()
//}
