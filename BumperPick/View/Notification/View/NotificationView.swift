//
//  NotificationView.swift
//  BumperPick
//
//  Created by tauseef hussain on 18/07/25.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedNotification: AppNotification? = nil

    let notifications: [AppNotification] = [
        AppNotification(title: "New Offer!", message: "Check out the latest 50% off deal in your area.", date: "July 18, 2025 10:15 AM", isRead: false),
        AppNotification(title: "Welcome to BumperPick", message: "Thank you for joining us!", date: "July 17, 2025 03:45 PM", isRead: true),
        AppNotification(title: "Referral Bonus", message: "You earned ₹100 for referring a friend.", date: "July 16, 2025 11:20 AM", isRead: true)
    ]

    var body: some View {
        VStack(spacing: 0) {
            CustomHeaderViewNew(
                title: "Notifications",
                showBackButton: true,
                backAction: { dismiss() },
                searchText: .constant(""),
                searchPlaceholder: "",
                showSearchBar: false
            )

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(notifications) { notification in
                        Button(action: {
                            selectedNotification = notification
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(notification.isRead ? Color.gray.opacity(0.3) : appThemeRedColor)
                                    .frame(width: 10, height: 10)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text(notification.message)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)

                                    Text(notification.date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
              //  .padding(.top)
           }
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
        .sheet(item: $selectedNotification) { notification in
            NotificationDetailView(notification: notification)
        }
        .navigationBarHidden(true)
    }
}

struct NotificationDetailView: View {
    let notification: AppNotification
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(notification.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(notification.message)
                    .font(.body)

                Text("Date: \(notification.date)")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
            .navigationTitle("Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}


//#Preview {
//    NotificationView()
//}
