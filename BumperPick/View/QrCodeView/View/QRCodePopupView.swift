//
//  QRCodePopupView.swift
//  BumperPick
//
//  Created by tauseef hussain on 08/06/25.
//


import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodePopupView: View {
    @Environment(\.dismiss) var dismiss
    let customerId: Int
    let offerId: Int
    let isQrCodeSavedToCart: Bool
    let onGoBackToHome: () -> Void

    let onSaveToCart: () -> Void
    @StateObject private var viewModel = QRCodePopupViewModel()

    @State private var showAlert = false
  //  @State private var alertMessage = ""
    
    var body: some View {
        ZStack {

        VStack(spacing: 10) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            // Close Button
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                }
            }
            
            Image(uiImage: generateQRCode(from: ["customer_id": customerId, "offer_id": offerId]))
                .interpolation(.none)
                .resizable()
                .frame(width: 200, height: 200)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, -30)
            
            // Message
            if isQrCodeSavedToCart {
                Text("Present this QR code at the outlet")
                    .font(.headline)
                    .padding(.top,15)
                    .padding(.bottom, 15)
            } else {
                Text("QR Code generated")
                    .font(.headline)
                
                Text("Now visit the outlet and present the QR code")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            Button(action: {
                if !isQrCodeSavedToCart {
                    viewModel.saveToCart(customerId: customerId, offerId: offerId, token: CustomerSession.shared.token ?? "") { result in
                        switch result {
                        case .success:
                            showAlert = true
                        case .failure:
                            showAlert = true
                        }
                    }
                } else {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onGoBackToHome() // ✅ Ask parent to navigate
                    }
                }
            }) {
                Text(isQrCodeSavedToCart ? "Go Back" : "Save to the cart")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(appThemeRedColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            //
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .edgesIgnoringSafeArea(.bottom)
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("BumperPick"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.success {
                        onSaveToCart()
                        dismiss() // Dismiss only after user taps OK
                    }
                }
            )
        }
    }
        
        if viewModel.isLoading {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
        ProgressView("Please wait...")
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.5)
            .foregroundColor(.white)
    }
}

    func generateQRCode(from dictionary: [String: Any]) -> UIImage {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }

        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        guard let outputImage = filter.outputImage else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }

        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        let context = CIContext()

        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            let size = CGSize(width: scaledImage.extent.width, height: scaledImage.extent.height)
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: size))
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return finalImage ?? UIImage()
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}




//#Preview {
//    QRCodePopupView(
//        customerId: 123,
//        offerId: 456,
//        isQrCodeSavedToCart: true,
//        onSaveToCart: {
//            print("Saved to cart from preview")
//        }
//    )
//}
//
