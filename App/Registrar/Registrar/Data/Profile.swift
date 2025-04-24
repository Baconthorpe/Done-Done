//
//  Profile.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/9/25.
//

import FirebaseFirestore

struct Profile: Codable, Identifiable {

    var id: String { userID }
    let userID: String
    let name: String
    let memberGroups: [String]
    let organizerGroups: [String]
    let attendingEvents: [String]

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let userID = "userID"
        static let name = "name"
        static let memberGroups = "memberGroups"
        static let organizerGroups = "organizerGroups"
        static let attendingEvents = "attendingEvents"
    }

    struct Draft {
        let name: String
        let memberGroups: [String] = []
        let organizerGroups: [String] = []
        let attendingEvents: [String] = []

        func asDictionary() -> [String: Any] {
            [DatabaseKey.name: name,
             DatabaseKey.memberGroups: memberGroups,
             DatabaseKey.organizerGroups: organizerGroups,
             DatabaseKey.attendingEvents: attendingEvents]
        }
    }

    static func from(dictionary: [String: Any]) -> Self? {
        Self(
            userID: dictionary[DatabaseKey.userID] as? String ?? "",
            name: dictionary[DatabaseKey.name] as? String ?? "",
            memberGroups: dictionary[DatabaseKey.memberGroups] as? [String] ?? [],
            organizerGroups: dictionary[DatabaseKey.organizerGroups] as? [String] ?? [],
            attendingEvents: dictionary[DatabaseKey.attendingEvents] as? [String] ?? []
        )
    }
}
