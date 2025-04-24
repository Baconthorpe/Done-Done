//
//  Provide.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine

enum Provide {
    enum Failure: Error {
        case actionRequiresProfile
    }

    // MARK: - Sign In
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

    // MARK: - Profiles
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

    // MARK: - Groups
    static func createGroup(name: String, description: String) -> AnyPublisher<Group, Error> {
        Just(Local.profile)
            .tryMap {
                guard let profile = $0 else { throw Failure.actionRequiresProfile }
                return (Group.Draft(name: name, description: description), profile)
            }
            .flatMap(FirebaseHandler.createGroup)
            .sideEffect({ group in
                guard let profile = Local.profile else { return }
                let updatedProfile = Profile(
                    userID: profile.userID,
                    name: profile.name,
                    memberGroups: profile.memberGroups + [group.id ?? ""],
                    organizerGroups: profile.organizerGroups + [group.id ?? ""],
                    attendingEvents: profile.attendingEvents
                )
                Local.profile = updatedProfile
            })
            .eraseToAnyPublisher()
    }

    static func sendGroupInvitation(group: String, recipient: String) -> AnyPublisher<GroupInvitation, Error> {
        FirebaseHandler.sendGroupInvitation(GroupInvitation.Draft(group: group, recipient: recipient))
            .eraseToAnyPublisher()
    }

    static func getMyGroupInvitations() -> AnyPublisher<[GroupInvitation], Error> {
        FirebaseHandler.getMyGroupInvitations()
            .eraseToAnyPublisher()
    }

    static func acceptGroupInvitation(_ invitation: GroupInvitation) -> AnyPublisher<Void, Error> {
        FirebaseHandler.acceptGroupInvitation(invitation)
            .eraseToAnyPublisher()
    }

    static func getGroups() -> AnyPublisher<[Group], Error> {
        Just(Local.profile?.memberGroups)
            .map { $0 ?? [] }
            .flatMap(FirebaseHandler.getGroups)
            .eraseToAnyPublisher()
    }

    static func getGroupOrganizers(_ group: Group) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getGroupOrganizers(group)
            .eraseToAnyPublisher()
    }

    static func getGroupMembers(_ group: Group) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getGroupMembers(group)
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
