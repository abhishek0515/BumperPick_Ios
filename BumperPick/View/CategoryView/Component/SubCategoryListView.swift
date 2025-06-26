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
    @State private var navigateToHome = false
    @State private var selectedSubCategoryID: Int?
    @State private var searchText: String = "" // ✅ Search text

    // Filtered subcategories
    var filteredSubCategories: [SubCategory] {
        if searchText.isEmpty {
            return category.subCategories
        } else {
            return category.subCategories.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            CustomHeaderViewNew(
                title: category.name,
                showBackButton: true,
                backAction: { dismiss() },
                searchText: $searchText, searchPlaceholder: "Search subcategory"    // ✅ This will now work
            )
            .padding(.top, -40)

            // Title + underline
            subCategoryHeaderTitleSection()

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredSubCategories) { sub in
                        subCategoryRow(for: sub)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            NavigationLink(
                destination: selectedSubCategoryID.map { subID in
                    HomeView(categoryID: category.id, subCategoryID: subID)
                },
                isActive: $navigateToHome
            ) {
                EmptyView().hidden()
            }


            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarHidden(true)
      //  .edgesIgnoringSafeArea(.top)
    }

    // MARK: - Title Header
    private func subCategoryHeaderTitleSection() -> some View {
        VStack(spacing: 4) {
            HStack {
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                Text("SUB CATEGORIES")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .fixedSize()
                    .layoutPriority(1)
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
            }
            .padding(.horizontal)

            Text("Select a subcategory")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 16)
    }

    // ✅ Search bar view
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search subcategory", text: $searchText)
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
        .padding(.horizontal) // Padding around search bar
    }

    private func subCategoryRow(for sub: SubCategory) -> some View {
        Button {
            selectedSubCategoryID = sub.id
            navigateToHome = true
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


struct CustomHeaderViewNew: View {
    let title: String
    let showBackButton: Bool
    let backAction: () -> Void
    @Binding var searchText: String   // ✅ Add this line
    let searchPlaceholder: String //Search subcategory
    var body: some View {
        VStack(spacing: 12) {
            // 🔙 Back button + title
            HStack {
                if showBackButton {
                    Button(action: backAction) {
                        Image("back")
                            .foregroundColor(.white)
                            .padding(.trailing, 4)
                    }
                }

                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal)

            // 🔍 Search bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField(searchPlaceholder, text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 50)
        .padding(.bottom, 12)
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
        .edgesIgnoringSafeArea(.top)
    }
}
