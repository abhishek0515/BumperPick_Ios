//
//  SupportTicketDetailResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/07/25.
//
import Foundation

struct SupportTicketDetailResponse: Codable {
    let code: Int
    let data: SupportTicketDetail
}

struct SupportTicketDetail: Codable {
    let id: Int
    let subject: String
    let status: String
    let createdAt: String
    let sender: Sender
    let messages: [TicketMessage]

    enum CodingKeys: String, CodingKey {
        case id, subject, status, sender, messages
        case createdAt = "created_at"
    }
}
//MARK: response of reply supportTicket
struct SupportTicketReplyResponse: Codable {
    let code: Int
    let message: String
    let data: SupportTicketData
}

