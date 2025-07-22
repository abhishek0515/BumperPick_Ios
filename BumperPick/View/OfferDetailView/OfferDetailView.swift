//
//  OfferDetailView.swift
//  BumperPick
//
//  Created by tauseef hussain on 09/06/25.
//
import SwiftUI


struct OfferDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showQRSheet = false
    let offerID: String
    @State private var isQRCodeSaved = false
    @State private var navigateToHome = false
    let isQRShow: Bool
    @State private var showFeedbackSheet = false
    @State private var vStackHeight: CGFloat = 0 // we are taking this because frmae unioun image will manage the height
    @StateObject private var viewModel = OfferDetailViewModel()
 //   @Binding var didToggleFavourite: Bool

    
    var body: some View {
        ZStack {
            if let offer = viewModel.offer {
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        HeaderSection(offer: offer)
                        VStack(spacing: 15) {
                            HStack(alignment: .center, spacing: 8) {
                                Text("Offer details")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal)
                            
                            // Title and Location Info
                            VStack(alignment: .leading, spacing: 0) {
                                ZStack(alignment: .topTrailing) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 10) {
                                            Image("SaleRed")
                                                .foregroundColor(.white)
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(offer.title ?? "")
                                                    .font(.headline)
                                                    .foregroundColor(.black)
                                                Text("Burger price: Rs. 150")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            }
                                        }.padding(.top, 10)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(red: 0.97, green: 0.96, blue: 1), Color.white]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    
                                    let validDate = convertDateFormate(offer.endDate ?? "", "yyyy-MM-dd", "dd MMM")
                                    Text("VALID TILL \(validDate)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                
                                // Bottom section
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Offline outlet offer only")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.black)
                                    
                                    Text(offer.description ?? "")
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                }
                                .padding()
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            // }
                            
                            // Redemption Steps
                            VStack(alignment: .leading, spacing: 20) {
                                HStack(alignment: .center, spacing: 8) {
                                    Text("How to redeem offer")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                }
                                // .padding(.horizontal)
                                
                                HStack(spacing: 12) {
                                    // Step 1
                                    ZStack(alignment: .bottomTrailing) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Step 1")
                                                .font(.caption)
                                                .foregroundColor(.black)
                                            
                                            Text("Go to cart to access the QR code")
                                                .font(.caption2)
                                                .foregroundColor(appThemeRedColor)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Image("ReedemedCart") // replace with your asset name
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .padding(8)
                                    }
                                    .background(Color.red.opacity(0.05))
                                    .cornerRadius(16)
                                    
                                    // Step 2
                                    ZStack(alignment: .bottomTrailing) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Step 2")
                                                .font(.caption)
                                                .foregroundColor(.black)
                                            
                                            Text("Present the QR code at the outlet")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Image("ReedemedQr") // replace with your asset name
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .padding(8)
                                    }
                                    .background(Color.blue.opacity(0.05))
                                    .cornerRadius(16)
                                }
                                
                            }
                            .padding(.horizontal)
                            if let media = offer.media {
                                PhotoGridView(mediaItems: media)
                            }
                            
                            if let reviews = offer.reviews, !reviews.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Customer Feedback & Ratings")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ForEach(reviews, id: \.id) { review in
                                        ReviewRowView(review: review)
                                            .padding(.horizontal)
                                    }
                                }
                                .padding(.top, 10)
                            }

                            
                            // PhotoGridView()
                        }
                        .padding(.top)
                        .padding(.bottom, 10)
                        
                        // 🔽 Bottom Button
                        VStack {
                            if isQRShow {
                                Button(action: {
                                    showQRSheet = true
                                }) {
                                    Text(isQRCodeSaved ? "Open QR" : "Avail offer")
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(appThemeRedColor)
                                        .cornerRadius(12)
                                }
                                .padding()
                                .padding(.bottom)
                            } else {
                                if !(offer.is_reviewed ?? false) {
                                    Button(action: {
                                        showFeedbackSheet = true
                                    }) {
                                        Text("Feedback & Rating")
                                            .font(.title3.bold())
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(appThemeRedColor)
                                            .cornerRadius(12)
                                    }
                                    .padding()
                                    .padding(.bottom)

                                }
                            }
                            
                        }
                        .background(Color.white.shadow(radius: 10))
                    }
                    .onChange(of: navigateToHome) { oldValue, newValue in
                        if newValue {
                            dismiss()
                        }
                    }
                    .sheet(isPresented: $showQRSheet) {
                        QRCodePopupView(
                            customerId: CustomerSession.shared.customerID ?? 0,
                            offerId: offer.id ?? 0,
                            isQrCodeSavedToCart: isQRCodeSaved,
                            onGoBackToHome: {
                                navigateToHome = true
                            }, onSaveToCart: {
                                isQRCodeSaved = true
                            }
                        )
                        // .environmentObject(tabManager)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                    }
                    .sheet(isPresented: $showFeedbackSheet) {
                        FeedbackDialogView(offer: offer, isPresented: $showFeedbackSheet) { rating, comment in
                            print("⭐️ Rating: \(rating), 📝 Comment: \(comment)")
                            // Call your API to submit feedback here
                            viewModel.sendFeedbackAndRating(
                                rating: String(rating),
                                comment: comment,
                                offerID: String(offer.id ?? 0)
                            )
                        }
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea(edges: .all)
                    .navigationBarHidden(true)
                }
            }
        }
        .onAppear() {
            viewModel.fetchOfferDetails(offerID: offerID)
        }
        .withLoader(viewModel.isLoading)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Offer Detail View"),
                message: Text(viewModel.alertMessage ?? "Something went wrong"),
                dismissButton: .default(Text("OK")) {
                   if  viewModel.dismissAfterSuccess {
                      // didToggleFavourite = true
                        dismiss()
                    }
                }
            )
        }
        .navigationBarHidden(true)
    }
    
    private func HeaderSection(offer: OfferDetail) -> some View {
        ZStack(alignment: .top) {
            Image("Burger")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: 450)
                .clipped()
            
            HStack {
                Button(action: { dismiss() }) {
                    Image("back2")
                        .padding()
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Button(action: {
                    viewModel.faverouiteTogelApi(offerId: offerID)
                }) {
                    Image(offer.isFavourited ? "heartFill" : "heart")
                        .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 40, height: 40)
                         .padding()
                }
                Button(action: {}) {
                    Image("share1")
                        .padding()
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal)
            .padding(.top, 44)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image("clock")
                    Text("OPEN FROM \(offer.openingTime ?? "") TO \(offer.closingTime ?? "")")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                HStack(alignment: .top) {
                    Text(offer.title ?? "")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                        .lineLimit(2)

                    Spacer()
                 //   let avgRating = Int(Double(from: offer.averageRating ?? 0))
                    let aveRating = Int(offer.averageRating ?? "") ?? 0
                    
                    RatingView(rating: .constant(aveRating), isInteractive: false, starSize: 14)
                }

                Text(offer.description ?? "")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .lineLimit(3)

                HStack(spacing: 8) {
                    Label {
                        Text("RESTAURANT")
                            .font(.caption.bold())
                            .foregroundColor(appThemeRedColor)
                    } icon: {
                        Image("restaurant")
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                    .padding(6)
                    .background(appThemeRedColor.opacity(0.1))
                    .cornerRadius(12)
                }

                Divider()
                HStack {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image("markerred")
                                .resizable()
                                .frame(width: 14, height: 14)
                            Text("Location")
                                .font(.caption)
                                .foregroundColor(.black)
                        } .frame(maxWidth: .infinity, alignment: .center)
                    }.padding()
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 40)
                    
                    Button(action: {
                        if let phoneNumber = offer.phone_number, !phoneNumber.isEmpty {
                            if let url = URL(string: "tel:\(phoneNumber)") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone")
                                .resizable()
                                .frame(width: 14, height: 14)
                            Text("Call")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }.padding()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.15), radius: 5)
            .padding(.horizontal)
            .offset(y: 200) //200
        }
        .frame(height: 420)
    }
}

struct ReviewRowView: View {
    let review: OfferReview

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Customer Name: \(review.customer_name ?? "")")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                RatingView(
                    rating: .constant(review.rating ?? 0),
                    isInteractive: false,
                    starSize: 14
                )
            }

            if let reviewText = review.review, !reviewText.isEmpty {
                Text(reviewText)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }

            Divider()
        }
        .padding(.vertical, 6)
    }
}


/// 1. Define a PreferenceKey to capture height
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

