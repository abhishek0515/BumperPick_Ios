//
//  ChooseLocationView.swift
//  BumperPick
//
//  Created by tauseef hussain on 14/06/25.
//


import SwiftUI

struct ChooseLocationView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                    // handle back
                }) {
                    Image("back")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }

                Text("Choose location")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.leading, 8)

                Spacer()
            }
            .padding()
            .background(Color.white)
            .overlay(
                Divider(),
                alignment: .bottom
            )

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search location (eg: Block B Malviya..)", text: .constant(""))
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding([.horizontal, .top], 16)

            // Current location option
            Button(action: {
                // handle use current location
            }) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(appThemeRedColor)

                    Text("Use my current location")
                        .foregroundColor(appThemeRedColor)
                        .font(.system(size: 16, weight: .semibold))

                    Spacer()

                    Image("arrowRight")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .padding(.top, 8)

            Divider()
                .padding(.horizontal)

            // Add new address option
            Button(action: {
                // handle add new address
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(appThemeRedColor)

                    Text("Add new address")
                        .foregroundColor(appThemeRedColor)
                        .font(.system(size: 16, weight: .semibold))

                    Spacer()
                }
                .padding()
            }

            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
}

//struct ChooseLocationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChooseLocationView()
//    }
//}
