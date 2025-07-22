//
//  HomeOfferCardView.swift
//  BumperPick
//
//  Created by tauseef hussain on 13/06/25.
//
import SwiftUI
import AVKit


struct CartOfferView: View {
    let offer: Offer
    @State private var selectedMediaIndex = 0
    @State private var navigateToEditScreen = false
    @State private var videoThumbnailCache: [Int: UIImage] = [:]
    @State private var playingVideoIndex: Int? = nil
    @State private var videoPlayers: [Int: AVPlayer] = [:]
    @State private var titleHeight: CGFloat = 0
    @State private var descriptionHeight: CGFloat = 0
    var onVisibilityChange: ((Bool) -> Void)? = nil
    @State private var showQRSheet = false
    let cartId: Int       // 🔸 Add this for delete cartoffer we used this
    @ObservedObject var viewModel: CartViewModel
    let isCart: Bool
    let isFavourite: Bool
    @State private var navigateToDetail = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                mediaCarouselView(for: offer)
                offerDetailsView
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 1)
            .padding()

            .onScrollVisibilityChange(coordinateSpace: "OfferScroll", visibleHeight: 300) { isVisible in
                handleVisibilityChange(isVisible: isVisible)
            }
            .onChange(of: selectedMediaIndex) { oldValue, newIndex in
                handleMediaIndexChange(newIndex: newIndex)
            }
            .onAppear { onVisibilityChange?(true) }
            .onDisappear { onVisibilityChange?(false) }
            
            if viewModel.isLoading {
                ProgressView("Deleting...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alerMessage ?? ""), dismissButton: .default(Text("OK")))
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            OfferDetailView(offerID: "\(offer.id ?? 0)", isQRShow: isCart)
        }
    }


    @ViewBuilder
    private func mediaCarouselView(for offer: Offer) -> some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedMediaIndex) {
                ForEach((offer.media ?? []).indices, id: \ .self) { index in
                    let media = (offer.media ?? [])[index]

                    ZStack {
                        if media.type == "image" {
                            imageView(for: media, index: index)
                        } else {
                            videoView(for: media, index: index)
                        }
                        mediaOverlay(for: media, at: index, total: offer.media?.count ?? 0, quantity: offer.quantity ?? 0)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: UIScreen.main.bounds.width * 9 / 16)
          //  deleteButton
            deleteButton(for: cartId, isfavorite: isFavourite)
        }
    }

    private func deleteButton(for cartId: Int, isfavorite: Bool) -> some View {
        VStack {
            Button(action: {
                let token = CustomerSession.shared.token ?? ""
                let itemID = isfavorite ? offer.id ?? 0 : cartId
                if isfavorite {
                    viewModel.faverouiteTogelApi(offerId: "\(itemID)")
                } else {
                    viewModel.deleteCartOffer(cartId: itemID, token: token)
                }
                
            }) {
                Image("delete")
                      .resizable()
                      .renderingMode(.template) // ensures tint applies
                      .foregroundColor(.white)
                      .padding(10)
                      .background(Color.black.opacity(0.3)) // ✅ adds contrast
                      .clipShape(Circle())
                      .frame(width: 50, height: 50)
            }

            .padding(8)
        }
    }

    private func mediaOverlay(for media: Media, at index: Int, total: Int, quantity: Int) -> some View {
        VStack {
            Spacer()
            HStack {
                ZStack {
                    if total > 1 {
                        HStack(spacing: 4) {
                            ForEach(0..<total, id: \.self) { index in
                                Circle()
                                    .fill(index == selectedMediaIndex ? appThemeRedColor : Color.white.opacity(0.6))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    HStack {
                        let itemQuantity = (offer.isUnlimited == 1) ? "Until Stock Last" : "\(offer.quantity ?? 0) left"
                        Text(itemQuantity)
                            .font(.footnote)
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(RightSideRoundedShape())
                        Spacer()

                    }
                }
            }
        }
    }
    
    private var offerDetailsView: some View {
        ZStack {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(offer.title ?? "")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear { titleHeight = geo.size.height }
                    })
                Spacer()
                let averageRating = Int(Double(offer.average_rating ?? "0") ?? 0.0)//Int(Double(offer.average_rating ?? 0))
                RatingView(rating: .constant(averageRating), isInteractive: false, starSize: 14)
            }

            HStack(alignment: .top) {
                Image("markerBlack")
                    .foregroundColor(.black)
                Text(offer.subheading ?? "")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear { descriptionHeight = geo.size.height }
                    })
            }
            DashedDivider()
            HStack(spacing: 4) {
                Image("SaleRed")
                    .foregroundColor(appThemeRedColor)
                Text(offer.description ?? "")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .cornerRadius(5)
            }
            if isCart {
                Button(action: {
                    showQRSheet  = true
                }) {
                    Text("Open QR")
                        .fontWeight(.semibold)
                        .foregroundColor(appThemeRedColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
            if !isCart {
                Button(action: {
                    print("Offer details tapped")
                    navigateToDetail = true
                    // Your action here
                }) {
                    Color.clear
                }
            }
      
    }  .sheet(isPresented: $showQRSheet) {
        QRCodePopupView(
            customerId: CustomerSession.shared.customerID ?? 0,
            offerId: offer.id ?? 0,
            isQrCodeSavedToCart: true,
            onGoBackToHome: {
                // navigateToHome = true
            }, onSaveToCart: {
                //isQRCodeSaved = true
            }
        ).presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
    }

}

    private func handleVisibilityChange(isVisible: Bool) {
        if !isVisible {
            for (_, player) in videoPlayers {
                player.pause()
                player.seek(to: .zero)
            }
            playingVideoIndex = nil
        } else if let index = playingVideoIndex,
                  selectedMediaIndex == index,
                  let player = videoPlayers[index] {
            player.play()
        }
    }

    private func handleMediaIndexChange(newIndex: Int) {
        if let playingIndex = playingVideoIndex, playingIndex != newIndex {
            videoPlayers[playingIndex]?.pause()
            videoPlayers[playingIndex]?.seek(to: .zero)
            playingVideoIndex = nil
        }
    }
    
//    private func imageView(for media: Media, index: Int) -> some View {
//        ZStack {
//            if videoThumbnailCache[index] == nil {
//                Color.gray.opacity(0.1)
//            }
//            if let image = videoThumbnailCache[index] {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(maxWidth: .infinity)
//                    .clipped()
//            } else {
//                ProgressView()
//                    .task {
//                        let mediaUrl = media.url ?? ""
//                        if let cached = VideoThumbnailCache.shared.object(forKey: mediaUrl as NSString) {
//                            videoThumbnailCache[index] = cached
//                        } else {
//                            Task.detached(priority: .background) {
//                                if let image = await loadImage(from: mediaUrl) {
//                                    await MainActor.run {
//                                        videoThumbnailCache[index] = image
//                                        VideoThumbnailCache.shared.setObject(image, forKey: mediaUrl as NSString)
//                                    }
//                                }
//                            }
//                        }
//                    }
//            }
//        }
//        .tag(index)
//        .frame(height: UIScreen.main.bounds.width * 9 / 16)
//        .clipped()
//    }
    
    private func imageView(for media: Media, index: Int) -> some View {
        ZStack {
            if videoThumbnailCache[index] == nil {
                Color.gray.opacity(0.1)
            }
            
            if let image = videoThumbnailCache[index] {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                Image("gallary")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .onAppear {
                        // Load only if not already cached
                        let mediaUrl = media.url ?? ""
                        if let cached = VideoThumbnailCache.shared.object(forKey: mediaUrl as NSString) {
                            videoThumbnailCache[index] = cached
                        } else {
                            Task.detached(priority: .background) {
                                if let image = await loadImage(from: mediaUrl) {
                                    await MainActor.run {
                                        videoThumbnailCache[index] = image
                                        VideoThumbnailCache.shared.setObject(image, forKey: mediaUrl as NSString)
                                    }
                                }
                            }
                        }
                    }
            }
        }
        .tag(index)
        .frame(height: UIScreen.main.bounds.width * 9 / 16)
        .clipped()
    }
    
        private func videoView(for media: Media, index: Int) -> some View {
            ZStack {
                if playingVideoIndex == index, let player = videoPlayers[index] {
                    VideoPlayer(player: player)
                        .onAppear {
                            player.play()
                        }
                        .onDisappear {
                            player.pause()
                            //  player.seek(to: .zero)
                        }
                } else if let thumbnail = videoThumbnailCache[index] {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
    
                    Button(action: {
                        if let url = URL(string: media.url ?? "") {
                            playVideo(at: index, url: url)
                        }
                    }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                } else {
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                    .task {
                        let mediaUrl = media.url ?? ""
                        if let cached = VideoThumbnailCache.shared.object(forKey: mediaUrl as NSString) {
                            videoThumbnailCache[index] = cached
                        } else {
                            Task.detached(priority: .background) {
                                if let image = await generateThumbnail(from: mediaUrl) {
                                    await MainActor.run {
                                        videoThumbnailCache[index] = image
                                        VideoThumbnailCache.shared.setObject(image, forKey: mediaUrl as NSString)
                                    }
                                }
                            }
                        }
                    }
    
                }
            }
            .tag(index)
            .frame(maxWidth: .infinity)
            .aspectRatio(16/9, contentMode: .fit)
            .clipped()
        }

    
    private func playVideo(at index: Int, url: URL) {
        for (idx, player) in videoPlayers where idx != index {
            player.pause()
            player.seek(to: .zero)
        }
        
        if let existingPlayer = videoPlayers[index] {
            playingVideoIndex = index
            existingPlayer.play()
        } else {
            let player = AVPlayer(url: url)
            videoPlayers[index] = player
            playingVideoIndex = index
            player.play()
        }
    }
    
    private func loadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
    
    private func generateThumbnail(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Failed to generate thumbnail: \(error)")
            return nil
        }
    }
}

//#Preview {
//    let mockMedia = [
//        Media(id: 1, type: "image", url: "https://picsum.photos/200/300"),
//        Media(id: 2, type: "video", url: "https://www.w3schools.com/html/mov_bbb.mp4")
//    ]
//
//    let mockOffer = Offer(
//        id: 123,
//        vendorID: 456,
//        title: "Flat 50% Off Flat 50% Off Flat 50% Off",
//        heading: "Exclusive Deal",
//        subheading: "Limited Time Offer",
//        discount: "50%",
//        brandName: "ElectroMart",
//        brandLogoURL: nil,
//        description: "Get flat 50% off on electronics. Limited time offer!",
//        terms: "Valid for 7 days",
//        startDate: "2025-06-01",
//        endDate: "2025-06-15",
//        approval: "approved",
//        quantity: 10,
//        expire: false,
//        status: "active",
//        media: mockMedia
//    )
//
//    return ScrollView(.vertical, showsIndicators: false) {
//        VStack(spacing: -10) {
//            ForEach(0..<3) { _ in
//                HomeOfferCardView(offer: mockOffer)
//                   // .frame(width: 280) // Adjust width to fit nicely in a row
//            }
//        }
//        .padding()
//    }
//}
