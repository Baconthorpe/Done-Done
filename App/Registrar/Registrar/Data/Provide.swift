//
//  Provide.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine

enum Provide {
    // MARK: - Sign In
    static func signInWithGoogle() -> AnyPublisher<Profile?, Error> {
        FirebaseHandler.signInWithGoogle()
            .flatMap(FirebaseHandler.getProfile)
            .sideEffect { Local.profile = $0 }
            .eraseToAnyPublisher()
    }

    static func signIn(email: String) -> AnyPublisher<Profile?, Error> {
        FirebaseHandler.signIn(email: email)
            .map { Local.email = $0 }
            .flatMap(FirebaseHandler.getProfile)
            .sideEffect { Local.profile = $0 }
            .eraseToAnyPublisher()
    }

    static func signInAnonymously() -> AnyPublisher<Profile?, Error> {
        FirebaseHandler.signInAnonymously()
            .flatMap(FirebaseHandler.getProfile)
            .sideEffect { Local.profile = $0 }
            .eraseToAnyPublisher()
    }

    // MARK: - Profiles
    static func createProfile(name: String) -> AnyPublisher<Profile, Error> {
        FirebaseHandler.createProfile(Profile.Draft(name: name))
            .eraseToAnyPublisher()
    }

    // MARK: - Groups
    static func createGroup(name: String, description: String) -> AnyPublisher<Group, Error> {
        FirebaseHandler.createGroup(Group.Draft(name: name, description: description))
            .eraseToAnyPublisher()
    }

    static func sendGroupInvitation(group: String, recipient: String) -> AnyPublisher<GroupInvitation, Error> {
        FirebaseHandler.sendGroupInvitation(GroupInvitation.Draft(group: group, recipient: recipient))
            .eraseToAnyPublisher()
    }

    static func getGroups() -> AnyPublisher<[Group], Error> {
        Just(Local.profile?.memberGroups)
            .map { $0 ?? [] }
            .flatMap(FirebaseHandler.getGroups)
            .eraseToAnyPublisher()
    }

    // MARK: - Events
    static func getMyEvents() -> AnyPublisher<[Event], Error> {
        FirebaseHandler.getMyEvents()
            .eraseToAnyPublisher()
    }

    static func getEventsForMyGroups() -> AnyPublisher<[Event], Error> {
        Just(Local.profile?.memberGroups)
            .map { $0 ?? [] }
            .flatMap(FirebaseHandler.getGroups)
            .map { $0.flatMap(\.events) }
            .flatMap(FirebaseHandler.getEvents)
            .eraseToAnyPublisher()
    }

    static func createEvent(title: String, description: String) -> AnyPublisher<Event, Error> {
        FirebaseHandler.createEvent(Event.Draft(title: title, description: description))
            .eraseToAnyPublisher()
    }

    static func getProfilesOfAttending(userIDs: [String]) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getProfilesOfAttending(userIDs: userIDs)
            .eraseToAnyPublisher()
    }
}
