//
//  FirebaseTickets.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 6/12/25.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

// MARK: - Ticket Methods
extension FirebaseHandler {
    static func createTicket(_ draft: Ticket.Draft) -> Future<Ticket, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            var formattedDraft = draft.asDictionary()
            formattedDraft[Ticket.DatabaseKey.creator] = currentUserID

            let newTicketRef = firestore.collection(DatabaseKey.event).addDocument(data: formattedDraft) { error in
                if let error = error {
                    promise(Result.failure(Failure.firebase(error)))
                    return
                }
            }

            let newTicket = Ticket(
                id: newTicketRef.documentID,
                creator: currentUserID,
                team: draft.team,
                title: draft.title,
                description: draft.description ?? "",
                priority: draft.priority,
                deadline: draft.deadline,
                dependencies: draft.dependencies,
                size: draft.size,
                tags: draft.tags
            )

            promise(Result.success(newTicket))
        }
    }

    static func getMyTickets() -> Future<[Event], Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            firestore
                .collection(DatabaseKey.event)
                .whereField(Event.DatabaseKey.creator, isEqualTo: currentUserID)
                .getDocuments { querySnapshot, err in
                    guard let querySnapshot = querySnapshot else {
                        promise(Result.failure(Failure.unknown))
                        return
                    }
                    let events: [Event] = querySnapshot.documents.compactMap { document in
                        try? document.data(as: Event.self)
                    }
                    promise(Result.success(events))
                }
        }
    }

    static func getTickets(eventIDs: [String]) -> Future<[Event], Error> {
        Future { promise in
            firestore
                .collection(DatabaseKey.event)
                .whereField(FieldPath.documentID(), in: eventIDs)
                .getDocuments { querySnapshot, err in
                    guard let querySnapshot = querySnapshot else {
                        promise(Result.failure(Failure.unknown))
                        return
                    }
                    let events: [Event] = querySnapshot.documents.compactMap { document in
                        try? document.data(as: Event.self)
                    }
                    promise(Result.success(events))
                }
        }
    }

//    static func getProfilesOfAttending(userIDs: [String]) -> Future<[Profile], Error> {
//        Future { promise in
//            guard !userIDs.isEmpty else {
//                promise(Result.success([]))
//                return
//            }
//
//            firestore
//                .collection(DatabaseKey.profile)
//                .whereField(Profile.DatabaseKey.userID, in: userIDs)
//                .getDocuments { querySnapshot, err in
//                    guard let querySnapshot = querySnapshot else {
//                        promise(Result.failure(Failure.unknown))
//                        return
//                    }
//                    let profiles: [Profile] = querySnapshot.documents.compactMap { document in
//                        try? document.data(as: Profile.self)
//                    }
//                    promise(Result.success(profiles))
//                }
//        }
//    }

//    static func sendEventInvitations(_ drafts: [EventInvitation.Draft]) -> Future<Void, Error> {
//        Future { promise in
//            guard currentUser != nil else { promise(Result.failure(Failure.signInNeeded)); return }
//
//            let batch = firestore.batch()
//            let formattedDrafts = drafts.map { $0.asDictionary() }
//
//            for draft in formattedDrafts {
//                batch.setData(draft, forDocument: firestore.collection(DatabaseKey.eventInvitation).document())
//            }
//
//            batch.commit { error in
//                if let error = error {
//                    promise(Result.failure(Failure.firebase(error)))
//                    return
//                }
//                promise(Result.success(()))
//            }
//        }
//    }

//    static func getEventInvitations() -> Future<[EventInvitation], Error> {
//        Future { promise in
//            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }
//
//            firestore
//                .collection(DatabaseKey.eventInvitation)
//                .whereField(EventInvitation.DatabaseKey.recipient, isEqualTo: currentUserID)
//                .getDocuments { querySnapshot, err in
//                    guard let querySnapshot = querySnapshot else {
//                        promise(Result.failure(Failure.unknown))
//                        return
//                    }
//                    let eventInvitationss: [EventInvitation] = querySnapshot.documents.compactMap { document in
//                        try? document.data(as: EventInvitation.self)
//                    }
//                    promise(Result.success(eventInvitationss))
//                }
//        }
//    }

//    static func acceptEventInvitation(_ eventInvitationID: String, eventID: String) -> Future<Void, Error> {
//        Future { promise in
//            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }
//
//            let profileRef = firestore.collection(DatabaseKey.profile).document(currentUserID)
//            let eventRef = firestore.collection(DatabaseKey.event).document(eventID)
//            let inviteRef = firestore.collection(DatabaseKey.eventInvitation).document(eventInvitationID)
//
//            firestore.runTransaction { transaction, errorPointer in
//                transaction.updateData(
//                    [Profile.DatabaseKey.attendingEvents: FieldValue.arrayUnion([eventID])],
//                    forDocument: profileRef
//                )
//                transaction.updateData(
//                    [Event.DatabaseKey.attending: FieldValue.arrayUnion([currentUserID])],
//                    forDocument: eventRef
//                )
//                transaction.deleteDocument(inviteRef)
//                return
//            } completion: { _, error in
//                if let error = error {
//                    promise(.failure(Failure.firebase(error)))
//                    return
//                }
//
//                promise(.success(()))
//            }
//        }
//    }

//    static func declineEventInvitation(_ eventInvitationID: String) -> Future<Void, Error> {
//        Future { promise in
//            let inviteRef = firestore.collection(DatabaseKey.eventInvitation).document(eventInvitationID)
//
//            inviteRef.delete { error in
//                if let error = error {
//                    promise(.failure(Failure.firebase(error)))
//                    return
//                }
//
//                promise(.success(()))
//            }
//        }
//    }
}
