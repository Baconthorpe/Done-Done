//
//  ProvideEvents.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/28/25.
//

import Foundation
import Combine

// MARK: - Event Methods
extension Provide {
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
