//
//  Group.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/8/25.
//

import FirebaseFirestore

struct Group: Codable, Identifiable {

    @DocumentID var id: String?
    let name: String
    let description: String
    let members: [String]
    let organizers: [String]
    let events: [String]

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let name = "name"
        static let description = "description"
        static let members = "members"
        static let organizers = "organizers"
        static let events = "events"
    }

    struct Draft {
        let name: String
        let description: String

        func asDictionary() -> [String: Any] {
            ["name": name,
             "description": description]
        }
    }
}
