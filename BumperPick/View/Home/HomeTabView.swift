//
//  Home.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/05/25.
//

import SwiftUI

enum HomeTab {
    case home, categouries, contest, account
}


struct HomeTabView: View {
    @State private var showOfferTypeSheet = false
    @State private var navigateToOfferBanner = false
    
    @State private var selectedTab: HomeTab


        // Updated initializer
        init(startingTab: HomeTab = .home) {
            _selectedTab = State(initialValue: startingTab)
        }
    
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .categouries:
                    CategorySelectionView()
                case .contest:
                    EmptyView()
                case .account:
                    AccountView()
                }
            }
            Spacer()
            Divider()
            // 🔻 Bottom Tab Bar
            Divider()
            
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == .home ? .blue : .gray)
                .onTapGesture {
                    selectedTab = .home
                }
                Spacer()
                
                VStack {
                    Image(systemName: "square.grid.2x2")
                    Text("Categouries")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == .categouries ? Color(AppString.colorPrimaryColor) : .gray)
                .onTapGesture {
                    selectedTab = .categouries
                }
                Spacer()
                
                VStack {
                    Image(systemName: "square.grid.2x2")
                    Text("Contest")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == .contest ? Color(AppString.colorPrimaryColor) : .gray)
                .onTapGesture {
                    selectedTab = .contest
                }
                Spacer()

                
                VStack {
                    Image(systemName: "person")
                    Text("Account")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == .account ? .blue : .gray)
                .onTapGesture {
                    selectedTab = .account
                }
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            
            .padding(.top, 8)
            .padding(.bottom, 16)

        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        }
}


class TabManager: ObservableObject {
    @Published var selectedTab: HomeTab = .home
    var isInitialLoad: Bool = true
}



//#Preview {
//    Home()
//}
