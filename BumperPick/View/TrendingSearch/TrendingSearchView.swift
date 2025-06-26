
import SwiftUI

struct TrendingSearchView: View {
    let trendingKeywords = ["Burger king", "Starbucks", "The London coffee", "Zykaaa", "Dominos", "Pizza hut"]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                         Button(action: {
                             dismiss()
                         }) {
                             Image("back")
                         }

                         TextField("Search for “Reliance mart”", text: .constant(""))
                             .padding(10)
                             .background(Color(.systemGray6))
                             .cornerRadius(10)
                     }
                     .padding()
                     .background(Color.white)

            // Trending header
            Text("Trending searches in food & drinks")
                .font(.headline)
                .padding(.horizontal)
               // .padding(.top, 16) // Add some spacing only above WrapHStack
                .padding(.bottom, 4)

            // Wrap search tags
            WrapHStack(data: trendingKeywords) { keyword in
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.red)
                    Text(keyword)
                        .font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3))
                )
            }
            .padding(.horizontal)
          //  .padding(.top, 8)

           // Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}


#Preview {
    TrendingSearchView()
}

struct WrapHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let lineSpacing: CGFloat
    let content: (Data.Element) -> Content

    init(data: Data,
         spacing: CGFloat = 8,
         lineSpacing: CGFloat = 8,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
                    .padding(.horizontal, 4)
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height + lineSpacing
                        }
                        let result = width
                        width -= d.width + spacing
                        return result
                    }
                    .alignmentGuide(.top) { _ in height }
            }
        }
    }
}

