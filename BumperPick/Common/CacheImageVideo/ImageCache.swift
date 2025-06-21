//
//  ImageCache.swift
//  BumperPick
//
//  Created by tauseef hussain on 11/06/25.
//


import SwiftUI
import AVKit

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    func load(from urlString: String) {
        if let cached = ImageCache.shared.object(forKey: urlString as NSString) {
            self.image = cached
            return
        }

        guard let url = URL(string: urlString) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    ImageCache.shared.setObject(image, forKey: urlString as NSString)
                    await MainActor.run { self.image = image }
                }
            } catch {
                print("Image load failed: \(error)")
            }
        }
    }
}

struct CachedImageView: View {
    let url: String
    @StateObject private var loader = ImageLoader()

    var body: some View {
        Group {
            if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Color.gray.opacity(0.1)
                    ProgressView()
                }
            }
        }
        .onAppear {
            loader.load(from: url)
        }
    }
}

//MARK: this cache is usinf for video
class VideoThumbnailCache {
    static let shared = NSCache<NSString, UIImage>()
}

class VideoPlayerCache {
    static let shared = NSCache<NSString, AVPlayer>()
}
