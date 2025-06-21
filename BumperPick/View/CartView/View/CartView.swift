//
//  CartView.swift
//  BumperPick
//
//  Created by tauseef hussain on 10/06/25.
//


import SwiftUI

struct CartView: View {
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CartViewModel()
    var categoryID: Int?
      var subCategoryID: Int?
    
    // Computed filtered offers based on searchText
    private var filteredOffers: [Offer] {
        viewModel.cartItem.map { $0.offer }.filter {
            searchText.isEmpty ||
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    VStack {
                        HStack(spacing: 12) {
                            Button(action: {
                                dismiss()
                            }) {
                                Image("back")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.black)
                                    .frame(width: 22, height: 22)
                            }
                            
//                            Text("Cart")
//                                .font(.title3.bold())
//                                .foregroundColor(.black)
                            Text(categoryID == nil && subCategoryID == nil ? "Cart" : "Offers")
                                .font(.title3.bold())
                                .foregroundColor(.black)

                            
                            Spacer()
                        }
                        .padding()
                        
                        // MARK: - Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                            
                            TextField("Search for \"Reliance mart\"", text: $searchText)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                    .background(.white)
                    
                    // MARK: - Offers Header (Now using filteredOffers)
                    HStack(spacing: 6) {
                        Image("leftArrow")
                            .resizable()
                            .frame(width: 10, height: 10)
                        
                        Text("\(filteredOffers.count) OFFER\(filteredOffers.count == 1 ? "" : "S") SAVED")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        Image("rightArrow")
                            .resizable()
                            .frame(width: 10, height: 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, -10)
                                        
                    // MARK: - ScrollView with filtered offers
                    ScrollView {
                        LazyVStack(spacing: -10) {
                            let matchingCartOffers = filteredOffers.compactMap { offer -> (Offer, Int)? in
                                if let cartItem = viewModel.cartItem.first(where: { $0.offer.id == offer.id }) {
                                    return (offer, cartItem.id)
                                }
                                return nil
                            }

                            ForEach(matchingCartOffers, id: \.0.id) { (offer, cartId) in
                                CartOfferView(offer: offer, cartId: cartId, viewModel: viewModel)
                                    .onScrollVisibilityChange(
                                        coordinateSpace: "OfferScroll",
                                        visibleHeight: 300
                                    ) { isVisible in
                                        // Optional visibility logic
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
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            let customerId = CustomerSession.shared.customerID ?? 0
            let token = CustomerSession.shared.token ?? ""
            viewModel.fetchCartOffers(customerId: customerId, token: token)
        }
    }
}


//#Preview {
//    CartView()
//}
