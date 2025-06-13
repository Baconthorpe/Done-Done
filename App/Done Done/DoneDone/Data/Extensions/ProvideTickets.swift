//
//  ProvideTickets.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 6/12/25.
//

import Foundation
import Combine

// MARK: - Ticket Methods
extension Provide {
    static func getMyTickets() -> AnyPublisher<[Event], Error> {
        FirebaseHandler.getMyEvents()
            .eraseToAnyPublisher()
    }

    static func getTicketsForMyTeams() -> AnyPublisher<[Event], Error> {
        Just(Local.profile?.memberGroups)
            .map { $0 ?? [] }
            .flatMap(FirebaseHandler.getGroups)
            .map { $0.flatMap(\.events) }
            .flatMap(FirebaseHandler.getEvents)
            .eraseToAnyPublisher()
    }

    static func createTicket(title: String, description: String) -> AnyPublisher<Event, Error> {
        FirebaseHandler.createEvent(Event.Draft(title: title, description: description))
            .eraseToAnyPublisher()
    }

//    static func getProfilesOfAttending(userIDs: [String]) -> AnyPublisher<[Profile], Error> {
//        FirebaseHandler.getProfilesOfAttending(userIDs: userIDs)
//            .eraseToAnyPublisher()
//    }

//    static func sendEventInvitations(event: Event, recipients: [Profile]) -> AnyPublisher<Void, Error> {
//        Just(Local.profile)
//            .tryMap {
//                guard let profile = $0 else { throw Failure.actionRequiresProfile }
//                guard let eventID = event.id else { throw Failure.actionRequiresEventID }
//                return recipients.map {
//                    EventInvitation.Draft(
//                        event: eventID,
//                        eventName: event.title,
//                        senderName: profile.name,
//                        recipient: $0.id,
//                        recipientName: $0.name
//                    )
//                }
//            }
//            .flatMap(FirebaseHandler.sendEventInvitations)
//            .eraseToAnyPublisher()
//    }

//    static func getEventInvitations() -> AnyPublisher<[EventInvitation], Error> {
//        FirebaseHandler.getEventInvitations()
//            .eraseToAnyPublisher()
//    }

//    static func acceptEventInvitation(_ invitation: EventInvitation) -> AnyPublisher<Void, Error> {
//        Just(invitation)
//            .tryMap {
//                guard let invitationID = $0.id else { throw Failure.actionRequiresEventID }
//                return (invitationID, $0.event)
//            }
//            .flatMap(FirebaseHandler.acceptEventInvitation)
//            .eraseToAnyPublisher()
//    }

//    static func declineEventInvitation(_ invitation: EventInvitation) -> AnyPublisher<Void, Error> {
//        Just(invitation)
//            .tryMap {
//                guard let invitationID = $0.id else { throw Failure.actionRequiresEventID }
//                return invitationID
//            }
//            .flatMap(FirebaseHandler.declineEventInvitation)
//            .eraseToAnyPublisher()
//    }
}
