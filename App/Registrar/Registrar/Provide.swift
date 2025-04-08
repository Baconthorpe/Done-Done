//
//  Provide.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine

enum Provide {
    static func signInWithGoogle() -> Future<Bool, Error> {
        FirebaseHandler.signInWithGoogle()
    }

    static func signIn(email: String) -> Future<String, Error> {
        FirebaseHandler.signIn(email: email)
            .onValue { Local.email = $0 }
    }

    static func signInAnonymously() -> Future<Bool, Error> {
        FirebaseHandler.signInAnonymously()
    }

    static func getEvents() -> Future<[Event], Error> {
        FirebaseHandler.getMyEvents()
    }

    static func createEvent(title: String, description: String) -> Future<Bool, Error> {
        FirebaseHandler.createEvent(Event.Draft(title: title, description: description))
    }
}
