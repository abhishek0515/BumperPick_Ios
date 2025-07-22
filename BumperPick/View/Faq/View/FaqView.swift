//
//  FaqView.swift
//  BumperPick
//
//  Created by tauseef hussain on 15/07/25.
//

import SwiftUI

struct FaqView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedFAQ: Int?
    @StateObject private var viewModel = FaqViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Top header
            CustomHeaderViewNew(
                title: "Frequently Asked Questions",
                showBackButton: true,
                backAction: { dismiss() },
                searchText: .constant(""),
                searchPlaceholder: "",
                showSearchBar: false
            )

            // FAQ List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.faqData) { faq in
                        FAQItemView(
                            faq: faq,
                            isExpanded: expandedFAQ == faq.id,
                            onToggle: {
                                withAnimation {
                                    expandedFAQ = expandedFAQ == faq.id ? nil : faq.id
                                }
                            }
                        )
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, -30)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
        .onAppear() {
            viewModel.getFaq()
        }
        .withLoader(viewModel.isLoading)
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
}

struct FAQItemView: View {
    let faq: FAQItem
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(faq.question)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: isExpanded ? "minus.circle.fill" : "plus.circle.fill")
                    .foregroundColor(appThemeRedColor)
                    .font(.system(size: 20))
            }

            if isExpanded {
                Text(faq.answer)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .transition(.opacity)
                    .padding(.top, 4)
            }
        }
        .padding()
        .contentShape(Rectangle()) // makes the entire area tappable
        .onTapGesture {
            withAnimation {
                onToggle()
            }
        }
    }
}
