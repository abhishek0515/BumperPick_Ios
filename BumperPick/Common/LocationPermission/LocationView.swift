//
//  LocationAlert.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/05/25.
//

import SwiftUI

struct LocationPermissionView: View {
    @Binding var isPresented: Bool
    var onAllow: () -> Void
    var onDeny: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 20) {
                // Dismiss Button
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                        onDeny()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(16)
                    }
                }

                // Image
                Image(AppString.imageLocation)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.red)
                    .padding(.top, -40)

                // Title
                Text(AppString.locationPermissionRequired)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Description
                Text(AppString.allowingLocationAccess)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Allow Button
                Button(action: {
                    isPresented = false
                    onAllow() // 🔴 Request location permission here
                }) {
                    Text(AppString.allow)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(AppString.colorPrimaryColor))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // Don't Allow
                Button(action: {
                    isPresented = false
                    onDeny() // 🔴 Handle "Don't Allow" action
                }) {
                    Text(AppString.dontAllow)
                        .foregroundColor(Color(AppString.colorPrimaryColor))
                        .font(.body)
                        .padding(.bottom, 20)
                }
            }
            .background(
                Color.white
                    .clipShape(
                        RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                    )
            )
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.clear)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct LocationPermissionModifier: ViewModifier {
    @ObservedObject var locationManager: LocationManager
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()

                    LocationPermissionView(
                        isPresented: $isPresented,
                        onAllow: {
                            locationManager.requestPermission()
                        },
                        onDeny: {
                            print("User denied location permission popup")
                        }
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut, value: isPresented)
            }
        }
        .onAppear {
            updatePermissionPopup()
        }
        .onChange(of: locationManager.authorizationStatus) { _ in
            updatePermissionPopup()
        }
    }

    private func updatePermissionPopup() {
        switch locationManager.authorizationStatus {
        case .notDetermined, .denied, .restricted:
            isPresented = true
        default:
            isPresented = false
        }
    }
}

extension View {
    func withLocationPermissionPopup(locationManager: LocationManager, isPresented: Binding<Bool>) -> some View {
        self.modifier(LocationPermissionModifier(locationManager: locationManager, isPresented: isPresented))
    }
}
