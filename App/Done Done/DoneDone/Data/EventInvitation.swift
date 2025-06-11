//
//  EventInvitation.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 5/12/25.
//

import FirebaseFirestore

struct EventInvitation: Codable, Identifiable {

    @DocumentID var id: String?
    let event: String
    let eventName: String
    let sender: String
    let senderName: String
    let recipient: String
    let recipientName: String

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let event = "event"
        static let eventName = "eventName"
        static let sender = "sender"
        static let senderName = "senderName"
        static let recipient = "recipient"
        static let recipientName = "recipientName"
    }

    struct Draft {
        let event: String
        let eventName: String
        let senderName: String
        let recipient: String
        let recipientName: String

        func asDictionary() -> [String: Any] {
            [DatabaseKey.event: event,
             DatabaseKey.eventName : eventName,
             DatabaseKey.senderName : senderName,
             DatabaseKey.recipient : recipient,
             DatabaseKey.recipientName : recipientName]
        }
    }
}
