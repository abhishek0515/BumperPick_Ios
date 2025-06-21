//
//  GetStartted.swift
//  BumperPick
//
//  Created by tauseef hussain on 19/05/25.
//
import SwiftUI

struct GetStartted: View {
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    // Top Image Section (65% of screen height)
                    ZStack(alignment: .bottom) {
                        Image(AppString.imageGetStarted) // Replace with your image name
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.65)
                            .clipped()
 
                        // Sale icon positioned relatively
                        Image(AppString.imageSale)
                            .resizable()
                            .frame(width: 136, height: 136)
                            .offset(
                                x: -geometry.size.width * 0.25, // Tune this value
                                y: -geometry.size.height * 0.39 // Tune this value
                            )
                        
                    }
                    
                    // Bottom Section
                    VStack(spacing: 12) {
                        Text(AppString.yourGatewayToStunningOffer)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.top, 50)
                        
                        Text(AppString.findTheBestOffer)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        // ✅ NavigationLink wraps the Button
                        NavigationLink(destination: LoginView()) {
                            Text(AppString.getStarted)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(AppString.colorPrimaryColor))
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.clear)
                            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: -5)
                    )
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
    }
}


//struct OfferWelcomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        GetStartted()
//    }
//}
