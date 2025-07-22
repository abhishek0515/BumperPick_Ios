//
//  AppNotification.swift
//  BumperPick
//
//  Created by tauseef hussain on 18/07/25.
//
import Foundation

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: String
    let isRead: Bool
}
