//
//  EventCardView.swift
//  BumperPick
//
//  Created by tauseef hussain on 04/07/25.
//

import SwiftUI

struct EventCardView: View {

    let event: EventData
    @State private var naviagteToCampaignRegistration = false
    @State private var bannerImage: UIImage? = nil

    var body: some View {
        VStack {
            NavigationLink(destination: EventDetailView(event: event)) {
                contentView
            }
        }
        .contentShape(Rectangle())
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    if let image = bannerImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("gallary")
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                loadBannerImage()
                            }
                    }
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)
            }
            eventDetailView()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func eventDetailView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(event.title)
                .font(.headline)
                .foregroundColor(.black)

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                let startEventDate = convertDateFormate(event.startDate, "yyyy-MM-dd", "dd-MM-yyyy")
                Text("Event date: \(startEventDate)")
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image("clock")
                Text("Event time: \(event.startTime)")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding([.horizontal, .bottom])
    }
    
    private func loadBannerImage() {
        guard let urlString = event.bannerImageURL,
              let url = URL(string: urlString) else { return }

        if let cached = VideoThumbnailCache.shared.object(forKey: urlString as NSString) {
            bannerImage = cached
        } else {
            Task.detached(priority: .background) {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            bannerImage = image
                            VideoThumbnailCache.shared.setObject(image, forKey: urlString as NSString)
                        }
                    }
                } catch {
                    print("Failed to load banner image: \(error.localizedDescription)")
                }
            }
        }
    }

    
}

//#Preview {
//    EventCardView()
//}
