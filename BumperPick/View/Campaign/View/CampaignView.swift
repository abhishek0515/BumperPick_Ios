//
//  EventsScreenView.swift
//  BumperPick
//
//  Created by tauseef hussain on 27/06/25.
//

import SwiftUI

enum CampaignTab {
    case ongoing, yourCampaign
}

struct CampaignView: View {
    @State private var searchText = ""
    @State private var selectedTab: CampaignTab = .ongoing
    @StateObject private var viewModel = CampaignViewModel()
    @State private var selectedEventId: Int? = nil

    var filteredCampaigns: [CustomerCampaign] {
        let source = selectedTab == .ongoing ? viewModel.ongoingCampaign : viewModel.yourCampaign
        return source.filter {
            searchText.isEmpty ||
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            CampaignHeaderView(selectedTab: $selectedTab, searchText: $searchText)
            
            VStack(spacing: 20) {
                HStack {
                    Image("leftArrow")
                        .resizable()
                        .frame(width: 10, height: 10)
                    
                    Text("\(selectedTab == .ongoing ? "ON GOING" : "Your") campaigns")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    Image("rightArrow")
                        .resizable()
                        .frame(width: 10, height: 10)
                }
                
                if filteredCampaigns.isEmpty {
                    Spacer()
                    Text("No campaigns found")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(filteredCampaigns.enumerated()), id: \.element.id) { index, campaign in
                                CampaignCardView(campaign: campaign, selectedCampaignID: $selectedEventId)
                                .zIndex(Double(index))
                            }
                        }

                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            viewModel.fetchCampaign(token: CustomerSession.shared.token ?? "")
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .withLoader(viewModel.isLoading)
    }
}


//#Preview {
//    EventsScreenView()
//}

