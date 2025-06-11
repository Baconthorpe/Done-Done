//
//  ProvideSignIn.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/28/25.
//

import Foundation
import Combine

// MARK: - Sign In Methods
extension Provide {
    static func signInWithGoogle() -> AnyPublisher<Profile?, Error> {
        FirebaseHandler.signInWithGoogle()
            .flatMap(FirebaseHandler.getProfile)
            .sideEffect { Local.profile = $0 }
            .eraseToAnyPublisher()
    }

    static func signUp(email: String, password: String) -> AnyPublisher<Profile?, Error> {
        FirebaseHandler.createUser(email: email, password: password)
            .map { nil }
            .eraseToAnyPublisher()
    }

    static func signIn(email: String, password: String) -> AnyPublisher<Profile?, Error> {
        FirebaseHandler.signIn(email: email, password: password)
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
}
