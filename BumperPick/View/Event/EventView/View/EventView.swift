//
//  EventView.swift
//  BumperPick
//
//  Created by tauseef hussain on 04/07/25.
//

import SwiftUI

struct EventView: View {
    @State private var searchText = ""
    @StateObject private var viewModel = EventViewModel()
    @State private var selectedEventId: Int? = nil
    @Environment(\.dismiss) private var dismiss

    var filteredEvent: [EventData] {
        if searchText.isEmpty {
            return viewModel.event
        } else {
            return viewModel.event.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomHeaderViewNew(
                title: "Event",
                showBackButton: true,
                backAction: { dismiss() },
                searchText: $searchText, searchPlaceholder: "Search event"
            )
            VStack(spacing: 20) {
                HStack {
                    Image("leftArrow")
                        .resizable()
                        .frame(width: 10, height: 10)
                    
                    Text("\(viewModel.event.count) EVENT")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    Image("rightArrow")
                        .resizable()
                        .frame(width: 10, height: 10)
                }
                
                if filteredEvent.isEmpty {
                    Spacer()
                    Text("No event found")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(filteredEvent.enumerated()), id: \.element.id) { index, event in
                                EventCardView(event: event)
                                    .zIndex(Double(index))
                            }
                        }

                    }
                }
                
            }
            .padding(.vertical)
        }
        .onAppear {
            viewModel.fetchEvent(token: CustomerSession.shared.token ?? "")
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .withLoader(viewModel.isLoading)
    }

    
    
}

//#Preview {
//    EventView()
//}
