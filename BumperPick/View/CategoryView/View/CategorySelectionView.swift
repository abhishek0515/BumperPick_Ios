//
//  CategorySelectionView.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/06/25.
//
import SwiftUI

struct CategorySelectionView: View {
    @StateObject private var viewModel = CategorySelectionViewModel()
    @State private var searchText: String = ""

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return viewModel.categories
        } else {
            return viewModel.categories.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
              //  headerSection
               // CategoryHeaderView()
                CategoryHeaderView(searchText: $searchText)
                categoryHeaderTitleSection()
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredCategories) { category in
                            NavigationLink(destination: SubCategoryListView(category: category)) {
                                categoryRow(for: category)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                viewModel.fetchCategories()
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
            .withLoader(viewModel.isLoading)
        }
    }
    
    // MARK: - Category Title Section
    private func categoryHeaderTitleSection() -> some View {
        VStack(spacing: 4) {
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 1)
                Text("CATEGORIES")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 1)
            }
            .padding(.horizontal)

            Text("Choose your category")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 16)
    }


    private func categoryRow(for category: Category) -> some View {
        HStack(spacing: 12) {
            // Load image from URL
            AsyncImage(url: URL(string: category.imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Text(category.name)
                .foregroundColor(.primary)
                .font(.title2)
            Spacer()
            Image("arrowRight")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}


//struct CategorySelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategorySelectionView()
//            .previewDevice("iPhone 14 Pro")
//    }
//}
