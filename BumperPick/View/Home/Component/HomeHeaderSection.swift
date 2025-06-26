//
//  HomeHeaderSection.swift
//  BumperPick
//
//  Created by tauseef hussain on 09/06/25.
//

import SwiftUI

struct HomeHeaderSection: View {
    @State private var navigateToCart = false
    let categories: [Category]  // 👈 Add this
    @StateObject private var locationManager = LocationManager()
    @Binding var searchText: String
    var onSearchTapped: () -> Void  // ✅ New callback

    
    var body: some View {
        VStack(spacing: 16) {
            // 🔹 Top Location and Icon bar
            HStack {
                NavigationLink(destination: ChooseLocationView()) {
                    HStack {
                        Image("marker")
                        VStack(alignment: .leading) {
                            Text(locationTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(locationSubtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Image("dropDown")
                            .padding(.leading, 4)

                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
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
            }
            .padding()
            .foregroundColor(.white)

            // 🔹 Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for “Reliance mart”", text: $searchText)
                    .onTapGesture {
                        onSearchTapped()
                    }
                    .onChange(of: searchText) { _ in
                        onSearchTapped()
                    }

            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.1), radius: 4)
            .padding(.horizontal)

            // 🔹 Navigate to cart
            NavigationLink(destination: CartView(), isActive: $navigateToCart) {
                EmptyView()
            }

            // 🔹 Dynamic Categories
            if !categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.id) { category in
                            categoryButton(title: category.name, imageUrl: category.imageURL)
                        }
                    }
                    .padding()
                    .padding(.horizontal)
                    .padding(.top, -15)
                }
               // .padding(.top, 10)
            }
        }
        .padding(.top, 50)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 149/255, green: 0/255, blue: 47/255),
                    Color(red: 178/255, green: 0/255, blue: 58/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )

        .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
    }

    func categoryButton(title: String, imageUrl: String?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                .background(Color.clear)
                .cornerRadius(16)

            VStack {
                HStack {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding([.top, .leading], 15)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                            case .failure(_):
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding([.bottom, .trailing], 5)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding([.bottom, .trailing], 5)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(width: 100, height: 110)
    }
    
    private var locationTitle: String {
         if let placemark = locationManager.currentPlacemark {
             if let subLocality = placemark.subLocality,
                let thoroughfare = placemark.thoroughfare {
                 return "\(subLocality), \(thoroughfare)" //sector49 , shona road from sublocality + throughfare
             }
         }
         return "Detecting location..."
     }

     private var locationSubtitle: String {
         if let placemark = locationManager.currentPlacemark {
             return placemark.locality ?? "Gurugram" // grugram shona road from localitu + street
         }
         return ""
     }
    
//    if let location = locationManager.currentLocation {
//        Text("Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)")
//    }
    
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double

        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 1
            g = 1
            b = 1
        }

        self.init(red: r, green: g, blue: b)
    }
}


//
//#Preview {
//    let mockCategories: [Category] = [
//        Category(
//            id: 1,
//            name: "Groceries",
//            slug: "groceries",
//            imageURL: "https://via.placeholder.com/60",
//            subCategories: []
//        ),
//        Category(
//            id: 2,
//            name: "Electronics",
//            slug: "electronics",
//            imageURL: "https://via.placeholder.com/60",
//            subCategories: []
//        ),
//        Category(
//            id: 3,
//            name: "Fashion",
//            slug: "fashion",
//            imageURL: "https://via.placeholder.com/60",
//            subCategories: []
//        )
//    ]
//    
//    return HomeHeaderSection(categories: mockCategories)
//}
