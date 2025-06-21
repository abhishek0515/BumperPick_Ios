//
//  HomeOffer.swift
//  BumperPick
//
//  Created by tauseef hussain on 09/06/25.
//

import SwiftUI
import AVKit

struct HomeOfferCardView: View {
    let offer: Offer
    @State private var selectedMediaIndex = 0
    @State private var navigateToEditScreen = false
 //   @State private var showSheet = false
  //  @State private var showRemoveSheet = false
    @State private var videoThumbnailCache: [Int: UIImage] = [:]
    @State private var playingVideoIndex: Int? = nil
    @State private var videoPlayers: [Int: AVPlayer] = [:]
   // @State private var showSuccessAlert = false
    @State private var titleHeight: CGFloat = 0
    @State private var descriptionHeight: CGFloat = 0

    var onVisibilityChange: ((Bool) -> Void)? = nil
    @State private var navigateToDetail = false
   // @State private var videoThumbnailTapped = false

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            mediaCarouselView(for: offer)
            offerDetailsView
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 1)
        .padding()
        
        NavigationLink(
               destination: OfferDetailView(offer: offer),
               isActive: $navigateToDetail
           ) {
               EmptyView()
           }
           .hidden()
        
        .onScrollVisibilityChange(coordinateSpace: "OfferScroll", visibleHeight: 300) { isVisible in
            handleVisibilityChange(isVisible: isVisible)
        }
        .onChange(of: selectedMediaIndex) { newIndex in
            handleMediaIndexChange(newIndex: newIndex)
        }
        .onAppear { onVisibilityChange?(true) }
        .onDisappear { onVisibilityChange?(false) }
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
            favrouiteButton
        }
    }

    private var favrouiteButton: some View {
        VStack {
            Button(action: {
                
            }) {
                Image("heart")
                    .padding()
                    .frame(width: 40, height: 40)
                    .cornerRadius(5)
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
                      //  let itemQuantity = "\(offer.quantity)"
                        Text("\(quantity) left") // Replace with dynamic value if needed
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
            // Underlying content
            VStack(alignment: .leading, spacing: 10) {
                Text(offer.title ?? "")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear { titleHeight = geo.size.height }
                    })

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
            }
            .padding()

            // Transparent button on top
            Button(action: {
                print("Offer details tapped")
                navigateToDetail = true
                // Your action here
            }) {
                Color.clear
            }
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
                ProgressView()
                    .task {
                        let mediaUrl = media.url ?? ""
                        if let cached = VideoThumbnailCache.shared.object(forKey: mediaUrl as NSString) {
                            videoThumbnailCache[index] = cached
                        } else {
                            Task.detached(priority: .background) {
                                if let image = await loadImage(from: mediaUrl) {
                                    await MainActor.run {
                                        videoThumbnailCache[index] = image
                                        VideoThumbnailCache.shared.setObject(image, forKey: mediaUrl as! NSString)
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
