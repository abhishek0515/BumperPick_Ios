//
//  PhotoGridView.swift
//  BumperPick
//
//  Created by tauseef hussain on 09/06/25.
//
import SwiftUI
import AVKit

struct PhotoGridView: View {
    let mediaItems: [Media]
    @State private var displayedCount = 2

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 8) {
                Text("Photos")
                    .font(.headline)
                    .foregroundColor(.black)

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }

            if mediaItems.isEmpty {
                Text("No photos available")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 8) {
                    // Featured Image/Video
                    if let first = mediaItems.first, let urlString = first.url, let url = URL(string: urlString) {
                        ZStack {
                            if first.type == "image" {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                            } else {
                                VideoThumbnailView(videoURL: url)
                            }
                        }
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                        .cornerRadius(12)
                    }

                    // Grid (excluding first)
                    let gridMedia = Array(mediaItems.dropFirst())
                    let isShowingAll = displayedCount >= gridMedia.count
                    let visibleMedia = Array(gridMedia.prefix(displayedCount))
                    let showExtra = !isShowingAll
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(visibleMedia.indices, id: \.self) { index in
                            let item = visibleMedia[index]
                            MediaGridCell(item: item)
                        }
                        if showExtra {
                            let remaining = gridMedia.count - displayedCount
                            let nextItem = gridMedia[displayedCount] // Next media item after visible ones

                            Button {
                                withAnimation {
                                    displayedCount = gridMedia.count
                                }
                            } label: {
                                ZStack {
                                    if let urlString = nextItem.url, let url = URL(string: urlString) {
                                        if nextItem.type == "image" {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                            } placeholder: {
                                                Color.gray.opacity(0.2)
                                            }
                                        } else {
                                            VideoThumbnailView(videoURL: url)
                                        }
                                    } else {
                                        Color.gray.opacity(0.2)
                                    }

                                    // Dark overlay
                                    Rectangle()
                                        .fill(Color.black.opacity(0.5))

                                    Text("+\(remaining)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                            }
                        }

                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
}


struct MediaGridCell: View {
    let item: Media

    var body: some View {
        ZStack {
            if let urlString = item.url, let url = URL(string: urlString) {
                if item.type == "image" {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                } else {
                    VideoThumbnailView(videoURL: url)
                }
            }
        }
        .frame(width: 100, height: 100)
        .clipped()
        .cornerRadius(10)
    }
}


struct VideoThumbnailView: View {
    let videoURL: URL
    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
                ProgressView()
            }

            Image(systemName: "play.circle.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
        }
        .task {
            if thumbnail == nil {
                thumbnail = await generateThumbnail(from: videoURL)
            }
        }
    }

    private func generateThumbnail(from url: URL) async -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("❌ Thumbnail error: \(error.localizedDescription)")
            return nil
        }
    }
}
