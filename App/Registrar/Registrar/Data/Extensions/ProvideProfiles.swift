//
//  ProvideProfiles.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/28/25.
//

import Foundation
import Combine

// MARK: - Profile Methods
extension Provide {
    static func createProfile(name: String) -> AnyPublisher<Profile, Error> {
        FirebaseHandler.createProfile(Profile.Draft(name: name))
            .sideEffect {
                Local.profile = $0
            }
            .eraseToAnyPublisher()
    }

    static func searchForProfiles(name: String) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getProfilesByName(name)
            .eraseToAnyPublisher()
    }
}
