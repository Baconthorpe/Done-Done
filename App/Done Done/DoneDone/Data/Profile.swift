//
//  Profile.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/9/25.
//

import FirebaseFirestore

struct Profile: Codable, Identifiable, Hashable {

    var id: String { userID }
    let userID: String
    let name: String
    let tagline: String
    let icon: String
    let userTeam: String
    let memberTeams: [String]
    let leaderTeams: [String]

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let userID = "userID"
        static let name = "name"
        static let tagline = "tagline"
        static let icon = "icon"
        static let userTeam = "userTeam"
        static let memberTeams = "memberTeams"
        static let leaderTeams = "leaderTeams"
    }

    struct Draft {
        let name: String
        let tagline: String
        let icon: String
        let memberTeams: [String] = []
        let leaderTeams: [String] = []

        func asDictionary() -> [String: Any] {
            [DatabaseKey.name: name,
             DatabaseKey.tagline: tagline,
             DatabaseKey.icon: icon,
             DatabaseKey.memberTeams: memberTeams,
             DatabaseKey.leaderTeams: leaderTeams]
        }
    }

    static func from(dictionary: [String: Any]) -> Self? {
        Self(
            userID: dictionary[DatabaseKey.userID] as? String ?? "",
            name: dictionary[DatabaseKey.name] as? String ?? "",
            tagline: dictionary[DatabaseKey.tagline] as? String ?? "",
            icon: dictionary[DatabaseKey.icon] as? String ?? "",
            userTeam: dictionary[DatabaseKey.userTeam] as? String ?? "",
            memberTeams: dictionary[DatabaseKey.memberTeams] as? [String] ?? [],
            leaderTeams: dictionary[DatabaseKey.leaderTeams] as? [String] ?? []
        )
    }
}
