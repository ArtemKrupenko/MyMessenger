//
//  ConversationsModels.swift
//  Messenger
//
//  Created by Артем on 12.11.2021.
//

import Foundation

struct Conversation {
    public let id: String
    public let name: String
    public let otherUserEmail: String
    public let latestMessage: LatestMessage
}

struct LatestMessage {
    public let date: String
    public let text: String
    public let isRead: Bool
}
