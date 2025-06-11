//
//  Invitation.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/11/25.
//

import FirebaseFirestore

struct GroupInvitation: Codable, Identifiable {

    @DocumentID var id: String?
    let group: String
    let sender: String
    let senderName: String
    let recipient: String

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let group = "group"
        static let sender = "sender"
        static let senderName = "senderName"
        static let recipient = "recipient"
    }

    struct Draft {
        let group: String
        let senderName: String
        let recipient: String

        func asDictionary() -> [String: Any] {
            [DatabaseKey.group: group,
             DatabaseKey.senderName : senderName,
             DatabaseKey.recipient : recipient]
        }
    }

    struct WithGroup: Identifiable {
        var id: String { invitation.group }

        let invitation: GroupInvitation
        let group: Group
    }
}
