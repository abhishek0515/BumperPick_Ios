//
//  SupportTicketResponse.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/07/25.
//


import Foundation

//MARK: tikcet list response

struct SupportTicketListResponse: Codable {
    let code: Int
    let data: [SupportTicketItem]
}

struct SupportTicketItem: Codable, Identifiable {
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


struct TicketMessage: Codable, Identifiable {
    let id: Int
    let body: String
    let createdAt: String
    let author: Sender

    enum CodingKeys: String, CodingKey {
        case id, body, author
        case createdAt = "created_at"
    }
}



//MARK: ticket create response
struct SupportTicketResponse: Codable {
    let code: Int
    let message: String
    let data: SupportTicketData
}

struct SupportTicketData: Codable {
    let id: Int
    let subject: String
    let status: String
    let createdAt: String
    let sender: Sender

    enum CodingKeys: String, CodingKey {
        case id, subject, status
        case createdAt = "created_at"
        case sender
    }
}

struct Sender: Codable {
    let id: Int
    let type: String
    let name: String
    let email: String
}
