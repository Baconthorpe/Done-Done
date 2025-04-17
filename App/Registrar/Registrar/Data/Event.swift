//
//  Event.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/18/24.
//

import FirebaseFirestore

struct Event: Codable, Identifiable, Hashable {

    @DocumentID var id: String?
    let creator: String
    let title: String
    let description: String
    let attending: [String]

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let creator = "creator"
        static let title = "title"
        static let description = "description"
        static let attending = "attending"
    }

    struct Draft {
        let title: String
        let description: String
        let attending: [String] = []

        func asDictionary() -> [String: Any] {
            [DatabaseKey.title: title,
             DatabaseKey.description: description,
             DatabaseKey.attending : attending]
        }
    }
}
