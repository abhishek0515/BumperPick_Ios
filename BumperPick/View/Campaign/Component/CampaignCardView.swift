//
//  EventCardView.swift
//  BumperPick
//
//  Created by tauseef hussain on 01/07/25.
//
import SwiftUI

struct CampaignCardView: View {
    let campaign: CustomerCampaign
    @Binding var selectedCampaignID: Int?
    @State private var naviagteToCampaignRegistration = false
    @State private var bannerImage: UIImage? = nil

    var body: some View {
        VStack {
            contentView            
        }
        .contentShape(Rectangle())
        .navigationDestination(isPresented: $naviagteToCampaignRegistration) {
            CampaignRegistrationView(campaignID: selectedCampaignID ?? 0)
        }
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
                Text("\(campaign.numberOfParticipant) PARTICIPATED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            campaignDetailView()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func campaignDetailView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(campaign.title)
                .font(.headline)
                .foregroundColor(.black)

            HStack(spacing: 4) {
                Image("building")
                Text(campaign.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 4) {
                Image("deadline")
                Text("Deadline: \(campaign.endDate)")
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image("markerBlack")
                Text(campaign.address)
            }
            .font(.caption)
            .foregroundColor(.gray)
            DashedDivider()
            if campaign.isRegistered {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                    Text("You've already signed up for this campaign")
                }
                .font(.caption)
            } else {
                Button(action: {
                    print("Tapped Sign Up for id: \(campaign.id)")
                    selectedCampaignID = campaign.id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.naviagteToCampaignRegistration = true
                    }
                    //
                }) {
                    Text("Sign up now")
                        .font(.subheadline)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(appThemeRedColor, lineWidth: 1)
                        )
                }
                .foregroundColor(appThemeRedColor)
                .padding(.top, 4)
            }
        }
        .padding([.horizontal, .bottom])
    }
    
    private func loadBannerImage() {
        guard let urlString = campaign.bannerImageURL,
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
