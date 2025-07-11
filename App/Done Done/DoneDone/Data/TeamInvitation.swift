//
//  TeamInvitation.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 6/20/25.
//

import FirebaseFirestore

struct TeamInvitation: Codable, Identifiable {

    @DocumentID var id: String?
    let team: String
    let sender: String
    let recipient: String
    let info: Info

    struct Info: Codable {
        let teamName: String
        let senderName: String
    }

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let team = "team"
        static let sender = "sender"
        static let recipient = "recipient"
        static let info = "info"

        static let teamName = "teamName"
        static let senderName = "senderName"
    }

    struct Draft {
        let team: String
        let teamName: String
        let recipient: String
        let senderName: String

        func asDictionary() -> [String: Any] {
            [
                DatabaseKey.team: team,
                DatabaseKey.recipient: recipient,
                DatabaseKey.info : [
                    DatabaseKey.senderName: senderName,
                    DatabaseKey.teamName: teamName
                ]
            ]
        }
    }
}
