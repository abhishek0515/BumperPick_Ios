//
//  EventHeaderView.swift
//  BumperPick
//
//  Created by tauseef hussain on 27/06/25.
//
import SwiftUI

struct CampaignHeaderView: View {
    @Binding var selectedTab: CampaignTab
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToCart = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {                
                Button(action: {
                    dismiss()
                }) {
                    Image("back")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
                Text("Campaigns")
                    .font(.title3).bold()
                    .foregroundColor(.white)

                
                Spacer()
                HStack(spacing: 16) {
                    Button { navigateToCart = true } label: {
                        Image(systemName: "cart").foregroundColor(.white)
                    }
                    Button(action: {}) {
                        Image(systemName: "heart").foregroundColor(.white)
                    }
                    Button(action: {}) {
                        Image(systemName: "bell").foregroundColor(.white)
                    }
                }
                .font(.system(size: 18))
                //
            }
            .padding(.horizontal)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search Campaign...", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.primary)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Tab Bar
            HStack(spacing: 0) {
                VStack {
                    Button {
                        selectedTab = .ongoing
                    } label: {
                        Text("Ongoing campaigns")
                            .foregroundColor(selectedTab == .ongoing ? .white : .white.opacity(0.8))
                            .fontWeight(.semibold)
                    }

                    if selectedTab == .ongoing {
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(.white)
                            .cornerRadius(2)
                            .padding(.horizontal, 10)
                    }
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Button {
                        selectedTab = .yourCampaign
                    } label: {
                        Text("Your campaigns")
                            .foregroundColor(selectedTab == .yourCampaign ? .white : .white.opacity(0.8))
                            .fontWeight(.semibold)
                    }

                    if selectedTab == .yourCampaign {
                        Rectangle()
                            .frame(height: 4)
                            .foregroundColor(.white)
                            .cornerRadius(2)
                            .padding(.horizontal, 10)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 8)
        }
        .padding(.top, 50)
        .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 149/255, green: 0/255, blue: 47/255), Color(red: 178/255, green: 0/255, blue: 58/255)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
        .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
        .navigationDestination(isPresented: $navigateToCart) {
            CartView(isCart: true, isFavourite: false)
        }
    }
}
