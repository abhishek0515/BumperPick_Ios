//
//  EventDetailView.swift
//  BumperPick
//
//  Created by tauseef hussain on 04/07/25.
//

import SwiftUI

struct EventDetailView: View {
    let event: EventData
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            CustomHeaderViewNew(
                title: "Event Details",
                showBackButton: true,
                backAction: { dismiss() },
                searchText: .constant(""),
                searchPlaceholder: "",
                showSearchBar: false
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // 📸 Banner
                    if let urlString = event.bannerImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().frame(maxWidth: .infinity)
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        .clipped()
                    }

                    // 📝 Details
                    Group {
                        // 📝 Event Title & Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            if let description = event.description {
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineLimit(nil)
                            }
                        }
                        .padding(.bottom, 8)

                        // 📍 Event Information Section
                        Text("Event Information")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: 16) {
                            // Location Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(appThemeRedColor.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                    //    Image(systemName: "location.fill")
                                        Image("markerred")
                                            .foregroundColor(appThemeRedColor)
                                            .font(.system(size: 20))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Location")
                                            .font(.headline)
                                            .foregroundColor(appThemeRedColor)
                                        
                                        Text(event.address)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            // Date & Time Card
                            VStack(alignment: .leading, spacing: 16) {
                                // Start Date & Time
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(appThemeRedColor.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "calendar")
                                            .foregroundColor(appThemeRedColor)
                                            .font(.system(size: 20))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Event Start At")
                                            .font(.headline)
                                            .foregroundColor(appThemeRedColor)
                                        Text("\(convertDateFormate(event.startDate, "yyyy-MM-dd", "dd-MM-yyyy")) \(event.startTime)")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // End Date & Time (if available)
                                if let endDate = event.endDate {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "clock")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 20))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Event End At")
                                                .font(.headline)
                                                .foregroundColor(.blue)
                                            
                                            Text("\(convertDateFormate(endDate, "yyyy-MM-dd", "dd-MM-yyyy")) \(event.endTime ?? "TBD")")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .font(.body)

                    // 🎥 YouTube
                    if let videoID = event.youtubeLink, !videoID.isEmpty {
                        Text("YouTube Live Stream")
                            .font(.headline)
                            .padding(.top)

                        YouTubeLiveWebView(videoID: videoID)
                            .frame(height: 220)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    // 📘 Facebook
                    if let fbLink = event.facebookLink, !fbLink.isEmpty {
                        socialLinkButton(
                            urlString: fbLink,
                            title: "Watch on Facebook",
                            gradientColors: [
                                Color(red: 0.23, green: 0.35, blue: 0.60),
                                Color(red: 0.17, green: 0.42, blue: 0.75)
                            ]
                        )
                    }

                    // 📸 Instagram
                    if let instaLink = event.instagramLink, !instaLink.isEmpty {
                        socialLinkButton(
                            urlString: instaLink,
                            title: "Watch on Instagram",
                            gradientColors: [
                                Color(red: 0.93, green: 0.33, blue: 0.50),
                                Color(red: 0.98, green: 0.66, blue: 0.20),
                                Color(red: 0.99, green: 0.26, blue: 0.13)
                            ]
                        )
                    }
                }
                .padding()
            }
            .padding(.top, -50)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Social Button Generator
    @ViewBuilder
    private func socialLinkButton(urlString: String, title: String, gradientColors: [Color]) -> some View {
        Button {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.rectangle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))

                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
    }
}
