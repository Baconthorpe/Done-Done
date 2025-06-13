//
//  Ticket.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 6/11/25.
//

import FirebaseFirestore

struct Ticket: Codable, Identifiable, Hashable {

    @DocumentID var id: String?
    let creator: String
    let team: String
    let title: String
    let description: String
    let priority: Priority?
    let deadline: Date?
    let dependencies: [String]?
    let size: Size?
    let tags: [String]?

    struct DatabaseKey {
        private init() {}

        static let id = "id"
        static let creator = "creator"
        static let team = "team"
        static let title = "title"
        static let description = "description"
        static let priority = "priority"
        static let deadline = "deadline"
        static let dependencies = "dependencies"
        static let size = "size"
        static let tags = "tags"
    }

    struct Draft {
        let team: String
        let title: String
        let description: String?
        let priority: Priority?
        let deadline: Date?
        let dependencies: [String]?
        let size: Size?
        let tags: [String]?

        func asDictionary() -> [String: Any] {
            var dictionary: [String: Any] = [
                DatabaseKey.team: team,
                DatabaseKey.title: title,
                DatabaseKey.description: description ?? ""
            ]

            if let priority = priority {
                dictionary[DatabaseKey.priority] = priority.rawValue
            }
            if let deadline = deadline {
                dictionary[DatabaseKey.deadline] = deadline.deadlineFormat
            }
            if let dependencies = dependencies {
                dictionary[DatabaseKey.dependencies] = dependencies
            }
            if let size = size {
                dictionary[DatabaseKey.size] = size.rawValue
            }
            if let tags = tags {
                dictionary[DatabaseKey.tags] = tags
            }

            return dictionary
        }
    }

    enum Priority: String, Codable, Comparable {
        case low
        case high
        case veryHigh

        static func < (lhs: Priority, rhs: Priority) -> Bool {
            switch (lhs, rhs) {
            case (.low, .high), (.low, .veryHigh), (.high, .veryHigh):
                return true
            default:
                return false
            }
        }
    }

    enum Size: String, Codable, Comparable {
        case small
        case medium
        case large

        static func < (lhs: Size, rhs: Size) -> Bool {
            switch (lhs, rhs) {
            case (.small, .medium), (.small, .large), (.medium, .large):
                return true
            default:
                return false
            }
        }
    }
}
