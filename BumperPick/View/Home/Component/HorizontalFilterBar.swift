//
//  HorizontalFilterBar.swift
//  BumperPick
//
//  Created by tauseef hussain on 09/06/25.
//
import SwiftUI

struct HorizontalFilterBar: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(label: "Filters", icon: "line.3.horizontal.decrease.circle")
                FilterButton(label: "Sort by", icon: "arrow.up.arrow.down")
                FilterButton(label: "Offers")
                FilterButton(label: "Distance")
            }
            .padding(.horizontal)
        }
    }
}

struct FilterButton: View {
    var label: String
    var icon: String?

    init(label: String, icon: String? = nil) {
        self.label = label
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
            }
            Text(label)
            if label == "Sort by" {
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .font(.subheadline)
        .foregroundColor(.black)
    }
}
