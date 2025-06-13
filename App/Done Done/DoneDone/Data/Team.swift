//
//  Team.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 6/11/25.
//

import FirebaseFirestore

struct Team: Codable, Identifiable, Hashable {

    @DocumentID var id: String?
    let name: String
    let description: String
    let members: [String]
    let leaders: [String]
    let tickets: [String]

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let name = "name"
        static let description = "description"
        static let members = "members"
        static let leaders = "leaders"
        static let tickets = "tickets"
    }

    struct Draft {
        let name: String
        let description: String

        func asDictionary() -> [String: Any] {
            [DatabaseKey.name: name,
             DatabaseKey.description: description,
             DatabaseKey.tickets: []]
        }
    }
}
