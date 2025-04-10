//
//  Provide.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine

enum Provide {
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

    static func createGroup(name: String, description: String) -> AnyPublisher<Group, Error> {
        FirebaseHandler.createGroup(Group.Draft(name: name, description: description))
            .eraseToAnyPublisher()
    }

    static func getEvents() -> AnyPublisher<[Event], Error> {
        FirebaseHandler.getMyEvents()
            .eraseToAnyPublisher()
    }

    static func createEvent(title: String, description: String) -> AnyPublisher<Event, Error> {
        FirebaseHandler.createEvent(Event.Draft(title: title, description: description))
            .eraseToAnyPublisher()
    }
}
