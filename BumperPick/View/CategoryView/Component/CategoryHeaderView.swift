//
//  CategoryHeaderView.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/06/25.
//
import SwiftUI


struct CategoryHeaderView: View {
    @Binding var searchText: String  // <-- Add this
    @State private var navigateToCart = false
    @StateObject private var locationManager = LocationManager()

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
            
            // 🔍 Search bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search for category", text: $searchText)  // <-- BINDING
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal) // ✅ Add this line
            

            NavigationLink(destination: CartView(), isActive: $navigateToCart) {
                EmptyView()
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

    private var locationTitle: String {
         if let placemark = locationManager.currentPlacemark {
             if let subLocality = placemark.subLocality,
                let thoroughfare = placemark.thoroughfare {
                 return "\(subLocality), \(thoroughfare)"
             }
         }
         return "Detecting location..."
     }

     private var locationSubtitle: String {
         if let placemark = locationManager.currentPlacemark {
             return placemark.locality ?? "Gurugram"
         }
         return ""
     }
}
