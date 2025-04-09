//
//  Provide.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine

enum Provide {
    static func signInWithGoogle() -> Future<Profile?, Error> {
        FirebaseHandler.signInWithGoogle()
            .futureFlatMap(FirebaseHandler.getProfileIfItExists)
            .onValue { Local.profile = $0 }
    }

    static func signIn(email: String) -> Future<Profile?, Error> {
        FirebaseHandler.signIn(email: email)
            .futureMap { Local.email = $0 }
            .futureFlatMap(FirebaseHandler.getProfileIfItExists)
            .onValue { Local.profile = $0 }
    }

    static func signInAnonymously() -> Future<Profile?, Error> {
        FirebaseHandler.signInAnonymously()
            .futureFlatMap(FirebaseHandler.getProfileIfItExists)
            .onValue { Local.profile = $0 }
    }

    static func createGroup(name: String, description: String) -> Future<Group, Error> {
        FirebaseHandler.createGroup(Group.Draft(name: name, description: description))
    }

    static func getEvents() -> Future<[Event], Error> {
        FirebaseHandler.getMyEvents()
    }

    static func createEvent(title: String, description: String) -> Future<Event, Error> {
        FirebaseHandler.createEvent(Event.Draft(title: title, description: description))
    }
}
