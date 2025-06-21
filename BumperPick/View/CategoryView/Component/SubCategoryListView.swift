//
//  SubCategoryListView.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/06/25.
//

import SwiftUI

struct SubCategoryListView: View {
    let category: Category
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToCart = false
    @State private var selectedSubCategoryID: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Custom header
            CustomHeaderView(title: category.name, showBackButton: true) {
                dismiss()
            }
            .padding(.top, -40)

            // Title + underline section
            subCategoryHeaderTitleSection()

            // Subcategory List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(category.subCategories) { sub in
                        subCategoryRow(for: sub)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            NavigationLink(
                destination: selectedSubCategoryID.map { subID in
                    CartView(categoryID: category.id, subCategoryID: subID)
                },
                isActive: $navigateToCart
            ) {
                EmptyView().hidden()
            }

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Section Header with Title
    private func subCategoryHeaderTitleSection() -> some View {
        VStack(spacing: 4) {
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 1)
                Text("SUB CATEGORIES")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .fixedSize() // ⬅️ Prevents line break
                    .layoutPriority(1)
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 1)
            }
            .padding(.horizontal)

            Text("Select a subcategory")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 16)
    }

    // MARK: - Subcategory Cell
//    private func subCategoryRow(for sub: SubCategory) -> some View {
//        HStack(spacing: 12) {
//            Circle()
//                .fill(Color.red.opacity(0.2))
//                .frame(width: 44, height: 44)
//                .overlay(
//                    Text(String(sub.name.prefix(1)))
//                        .font(.headline)
//                        .foregroundColor(.red)
//                )
//
//            Text(sub.name)
//                .foregroundColor(.primary)
//                .font(.body)
//
//            Spacer()
//
//            Image("arrowRight")
//                .renderingMode(.template)
//                .foregroundColor(.gray)
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
//    }
    
    private func subCategoryRow(for sub: SubCategory) -> some View {
        Button {
            selectedSubCategoryID = sub.id
            navigateToCart = true
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(sub.name.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.red)
                    )

                Text(sub.name)
                    .foregroundColor(.primary)
                    .font(.body)

                Spacer()

                Image("arrowRight")
                    .renderingMode(.template)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

}
