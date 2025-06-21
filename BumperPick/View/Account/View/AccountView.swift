//
//  UpdatedAccountView.swift
//  BumperPick
//
//  Created by tauseef hussain on 18/06/25.
//


import SwiftUI

struct AccountView: View {
    @State private var notificationsEnabled = true
    @State private var isSharing = false
    @State private var navigateToNextScreen = false
    @StateObject private var viewModel = AccountViewModel()
    @State private var navigateToLogin = false

    var body: some View {
        ZStack {
        VStack(spacing: 0) {
            // MARK: Header
            CustomHeaderView(title: "Your Profile", showBackButton: false) {
                // Dismiss or navigation action
                print("Back tapped")
            }
            
            
            ScrollView {
                VStack(spacing: 12) {
                    
                    // MARK: Profile Card
                    profileCard
                    // MARK: Account Settings Section
                    
                    VStack(spacing: 0) {
                        sectionHeader(title: " ACCOUNT SETTINGS ")
                        navigationRow(icon: "clock", title: "Offer history") {
                            print("Offer history tapped")
                        }
                        Divider()
                        toggleRow(icon: "bell", title: "Notification setting", isOn: $notificationsEnabled)
                        Divider()
                        navigationRow(icon: "heart", title: "Favourites") {
                            print("Favourites tapped")
                        }
                    }
                    .background(Color.white)
                    
                    // MARK: Referral Section
                    
                    VStack(spacing: 12) {
                        sectionHeader(title: " REFERRAL ")
                        Image("referalImage") // Replace with your referral illustration
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                        
                        Text("Refer this app to your friends and family")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                        
                        Button(action: {
                            isSharing = true
                        }) {
                            Text("Refer now")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(appThemeRedColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .background(Color.white)
                    signOutRow
                }
                .padding(.vertical)
                .background(Color(.systemGroupedBackground))
            }
            NavigationLink(
                destination: EditProfileView(
                    name: viewModel.profile?.name ?? "",
                    phone: viewModel.profile?.phoneNumber ?? "",
                    email: viewModel.profile?.email ?? "",
                    imageURL: viewModel.profile?.imageURL
                ),
                isActive: $navigateToNextScreen
            ) {
                EmptyView()
            }
            NavigationLink(
                destination: LoginView(),
                isActive: $navigateToLogin
            ) {
                EmptyView()
            }
        }
        .blur(radius: viewModel.isLoading ? 3 : 0)
        .disabled(viewModel.isLoading)
        
        // MARK: - Loading Overlay
        if viewModel.isLoading {
            Color.black.opacity(0.25)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView("Loading...")
                .padding(20)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
    }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $isSharing) {
            ActivityView(activityItems: ["Check out this amazing app! Download now: https://your-app-link.com"])
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchProfile(token: CustomerSession.shared.token ?? "")
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.alerMessage ?? "Something went wrong"), dismissButton: .default(Text("OK")))
        }
    }
    
    private var signOutRow: some View {
        Button(action: {
            CustomerSession.shared.logout()
            navigateToLogin = true
        }) {
            HStack {
                Image("signOut")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
                Text("Sign out")
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .padding(.leading, 8)
                Spacer()
                Image("arrowRight")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
           // .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }


    // MARK: Profile Card
    private var profileCard: some View {
        HStack {
            if let imageUrlString = viewModel.profile?.imageURL,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 48, height: 48)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    case .failure:
                        Image("gallary")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image("gallary")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading) {
                Text(viewModel.profile?.name ?? "Name")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(viewModel.profile?.phoneNumber ?? "Phone")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Button(action: {
                print("Edit profile tapped")
                navigateToNextScreen = true
            }) {
                Image("editWhite")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
                    .padding(12)
            }
            .contentShape(Rectangle())
        }
        .padding()
        .background(Color(red: 114/255, green: 3/255, blue: 50/255))
        .cornerRadius(16)
        .padding(.horizontal)
    }


    // MARK: Section Header
    private func sectionHeader(title: String) -> some View {
        HStack(spacing: 4) {
            Image("leftArrow")
                .resizable()
                .frame(width: 10, height: 10)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Image("rightArrow")
                .resizable()
                .frame(width: 10, height: 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }

    // MARK: Navigation Row
    private func navigationRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(.black)
                Text(title)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .frame(height: 48)
        }
    }

    // MARK: Toggle Row
    private func toggleRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.black)
            Text(title)
                .foregroundColor(.black)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(appThemeRedColor)
        }
        .padding(.horizontal)
        .frame(height: 48)
    }
}

//#Preview {
//    AccountView()
//}
