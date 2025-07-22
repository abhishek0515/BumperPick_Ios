//
//  SortBySheetView.swift
//  BumperPick
//
//  Created by tauseef hussain on 13/07/25.
//
import SwiftUI

struct SortBySheetView: View {
    @Binding var selectedSort: String
    @Environment(\.dismiss) private var dismiss

    let sortOptions = [
        "Latest First (Default)",
        "Distance (Near to far)",
        "Distance (Far to near)",
        "Rating (High to low)"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            // Title
            Text("Sort by")
                .font(.headline)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.top)

            Divider()

            // Sort Options
            ForEach(sortOptions, id: \.self) { option in
                Button(action: {
                    selectedSort = option
                    dismiss()
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: selectedSort == option ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(selectedSort == option ? appThemeRedColor : .gray)
                    }
                    .padding()
                    .background(selectedSort == option ? appThemeRedColor.opacity(0.1) : Color.clear)
                }
                Divider()
            }

            Spacer(minLength: 16)
        }
       // .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

func sortByValue(from option: String) -> String {
    switch option {
    case "Latest First (Default)":
        return "1"
    case "Distance (Near to far)":
        return "2"
    case "Distance (Far to near)":
        return "3"
    case "Rating (High to low)":
        return "4"
    default:
        return "1" // fallback to default
    }
}


//#Preview {
//    let sortFirst = "Latest First (Default)"
//    SortBySheetView(selectedSort: $sortFirst)
//}
