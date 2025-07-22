//
//  RatingView.swift
//  BumperPick
//
//  Created by tauseef hussain on 08/07/25.
//
import SwiftUI

//struct RatingView: View {
//    @Binding var rating: Int
//    
//    var body: some View {
//        HStack {
//            ForEach(1...5, id: \.self) { index in
//                Image(systemName: rating >= index ? "star.fill" : "star")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                    .foregroundColor(.yellow)
//                    .onTapGesture {
//                        rating = index
//                    }
//            }
//        }
//    }
//}

struct RatingView: View {
    @Binding var rating: Int
    var isInteractive: Bool = true
    var starSize: CGFloat = 30

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: rating >= index ? "star.fill" : "star")
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        if isInteractive {
                            rating = index
                        }
                    }
            }
        }
    }
}

struct FeedbackDialogView: View {
    let offer: OfferDetail
    @Binding var isPresented: Bool
    @State private var rating: Int = 0
    @State private var comment: String = ""
    
    var onSubmit: (_ rating: Int, _ comment: String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Rate This Offer")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                Text(offer.title ?? "")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                Text(offer.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            RatingView(rating: $rating)
              //  .padding(.top)

            TextEditor(text: $comment)
                .frame(height: 100)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

            HStack(spacing: 16) {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)
                
                Spacer()

                Button("Submit") {
                    onSubmit(rating, comment)
                    isPresented = false
                }
                .disabled(rating == 0)
                .foregroundColor(.white)
                .padding()
                .background(appThemeRedColor)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .padding()
    }
}

//struct FeedbackDialogView: View {
//    let offer: Offer
//    @Binding var isPresented: Bool
//    @State private var rating: Int = 0
//    @State private var comment: String = ""
//    
//    var onSubmit: (_ rating: Int, _ comment: String) -> Void
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Rate This Offer")
//                .font(.title2.bold())
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text(offer.title ?? "")
//                    .font(.headline)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .lineLimit(nil)
//                Text(offer.description ?? "")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .lineLimit(nil)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            RatingView(rating: $rating)
//              //  .padding(.top)
//
//            TextEditor(text: $comment)
//                .frame(height: 100)
//                .padding(8)
//                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
//
//            HStack(spacing: 16) {
//                Button("Cancel") {
//                    isPresented = false
//                }
//                .foregroundColor(.red)
//                
//                Spacer()
//
//                Button("Submit") {
//                    onSubmit(rating, comment)
//                    isPresented = false
//                }
//                .disabled(rating == 0)
//                .foregroundColor(.white)
//                .padding()
//                .background(appThemeRedColor)
//                .cornerRadius(8)
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(16)
//        .padding()
//    }
//}
