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
    let offer: Offer
    @State private var isQRCodeSaved = false
    @State private var navigateToHome = false
    
    

    @State private var vStackHeight: CGFloat = 0 // we are taking this because frmae unioun image will manage the height

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    // 🔽 Your existing content here (unchanged)
                    // Header Image
                    ZStack(alignment: .top) {
                        Image("Burger")
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: 400)
                            .clipped()
                        // .ignoresSafeArea(edges: .top) // optional, if you want full top bleed
                        
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image("back2")
                                    .padding()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                            }
                            Spacer()
                            Button(action: {
                                
                            }) {
                                Image("heart")
                                    .padding()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                            }
                            Button(action: {
                                
                            }) {
                                Image("share1")
                                    .padding()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 44)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image("clock")
                                Text("OPEN FROM 09:00AM TO 11:00PM")
                                    .font(.caption)
                                    .foregroundColor(.blue)

                            }
                            Text(offer.title ?? "")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5) // Shrinks font if content exceeds 2 lines
                                .fixedSize(horizontal: false, vertical: true)
                            
                            
                            Text(offer.subheading ?? "")
                                .font(.footnote)
                                .foregroundColor(.black)
                                .lineLimit(3)
                                .minimumScaleFactor(0.5) // Shrinks font if content exceeds 2 lines
                                .fixedSize(horizontal: false, vertical: true)
                            
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
                            Button(action: {
                                // Your action here
                            }) {
                                HStack(spacing: 4) {
                                    Image("markerred")
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                    Text("Location")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        .offset(y: 200)
                    }
                    .frame(height: 395)
                    
                    
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
                        
                        // PhotoGridView()
                    }
                    .padding(.top)
                    .padding(.bottom, 10)
                    
//                    NavigationLink(destination: HomeTabView(startingTab: .home), isActive: $navigateToHome) {
//                        EmptyView()
//                    }

                    
                    // 🔽 Bottom Button
                    VStack {
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
                    }
                    .background(Color.white.shadow(radius: 10))
                }
                .onChange(of: navigateToHome) { newValue in
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
                
                .background(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea(edges: .all)
                .navigationBarHidden(true)
            }
        }
    }
}


//#Preview {
//    let mockOffer = Offer(
//        id: 1,
//        vendorID: 1,
//        title: "Flat Rs. 200 off on 3 burgers.",
//        heading: "Special Offer",
//        subheading: "Limited time only Limited time",
//        discount: "Rs. 200",
//        brandName: "Burger Palace",
//        brandLogoURL: nil,
//        description: "Get Rs. 200 off when you order 3 burgers. Only available at select outlets. ",
//        terms: "Valid for dine-in only. Not combinable with other offers.",
//        startDate: "2025-06-01",
//        endDate: "2025-06-30",
//        approval: "approved",
//        quantity: 100,
//        expire: false,
//        status: "active",
//        media: []
//    )
//
//    OfferDetailView(offer: mockOffer)
//}


/// 1. Define a PreferenceKey to capture height
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
