//
//  ChatModels.swift
//  Messenger
//
//  Created by Артем on 12.11.2021.
//

import Foundation
import CoreLocation
import MessageKit

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

struct Media: MediaItem {
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize
}

struct Location: LocationItem {
    public var location: CLLocation
    public var size: CGSize
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text: return "text"
        case .attributedText: return "attributed_text"
        case .photo: return "photo"
        case .video: return "video"
        case .location: return "location"
        case .emoji: return "emoji"
        case .audio: return "audio"
        case .contact: return "contact"
        case .linkPreview: return "linkPreview"
        case .custom: return "custom"
        }
    }
}
