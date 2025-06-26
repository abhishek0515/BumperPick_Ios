//
//  HomeView.swift
//  BumperPick
//
//  Created by tauseef hussain on 09/06/25.
//

import SwiftUI

struct HomeView: View {
    @State private var currentIndex = 0
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText: String = ""
    @StateObject private var locationManager = LocationManager()
    @State private var showPermissionPopup = false
    @EnvironmentObject var customerSession: CustomerSession
    var categoryID: Int?
    var subCategoryID: Int?
    @Environment(\.dismiss) private var dismiss
    @State private var showTrendingSearch = false

    
    var body: some View {
        if customerSession.isSessionLoaded {
            if let _ = customerSession.token {
        ScrollView {
            VStack(spacing: 16) {
                if categoryID == nil && subCategoryID == nil {
                   // HomeHeaderSection(categories: viewModel.categories, searchText: $searchText)
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
                    exploreEventsCard
                    trendingOffersCarousel
                    HorizontalFilterBar()
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
                        HomeOfferCardView(offer: offer)
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
                // .padding(.horizontal)
                .padding(.bottom, 20) // extra space to avoid clipping
                
                NavigationLink(destination: TrendingSearchView(), isActive: $showTrendingSearch) {
                    EmptyView()
                }
                .hidden()

            }
            .withLoader(viewModel.isLoading)
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if !viewModel.didFetchData {
                viewModel.fetchHomeData(categoryId: categoryID, subcategoryId: subCategoryID)
            }
//            viewModel.fetchHomeData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                locationManager.requestPermission()
            }
        }
        .withLocationPermissionPopup(locationManager: locationManager, isPresented: $showPermissionPopup)
        .navigationBarHidden(true)
    }
  }
}

    var exploreEventsCard: some View {
        HStack {
            Image("Speaker")
            Text("Explore exciting events near you")
                .font(.callout)
            Spacer()
            Image("arrowRight")
        }
        .padding()
        .background(Color(red: 1, green: 0.9, blue: 0.9))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 20)
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


//#Preview {
//    HomeView()
//}
