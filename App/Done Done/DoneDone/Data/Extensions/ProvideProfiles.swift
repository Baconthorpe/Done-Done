//
//  ProvideProfiles.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/28/25.
//

import Foundation
import Combine

// MARK: - Profile Methods
extension Provide {
    static func createProfile(name: String, tagline: String = "", icon: String = "") -> AnyPublisher<Profile, Error> {
        FirebaseHandler.createProfile(Profile.Draft(name: name, tagline: tagline, icon: icon))
            .sideEffect {
                Local.profile = $0
            }
            .eraseToAnyPublisher()
    }

    static func searchForProfiles(name: String) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getProfilesByName(name)
            .eraseToAnyPublisher()
    }

//    static func getProfilesForMembersOfMyGroups() -> AnyPublisher<[Profile], Error> {
//        Just(Local.profile)
//            .tryMap {
//                guard let profile = $0 else { throw Failure.actionRequiresProfile }
//                return profile.memberGroups
//            }
//            .flatMap(FirebaseHandler.getProfilesForGroups)
//            .eraseToAnyPublisher()
//    }
}
