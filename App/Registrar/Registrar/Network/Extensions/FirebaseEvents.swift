//
//  FirebaseEvents.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/28/25.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

// MARK: - Event Methods
extension FirebaseHandler {
    static func createEvent(_ draft: Event.Draft) -> Future<Event, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            var formattedDraft = draft.asDictionary()
            formattedDraft[Event.DatabaseKey.creator] = currentUserID

            let newEventRef = firestore.collection(DatabaseKey.event).addDocument(data: formattedDraft) { error in
                if let error = error {
                    promise(Result.failure(error))
                    return
                }
            }

            let newEvent = Event(
                id:             newEventRef.documentID,
                creator:        currentUserID,
                title:          draft.title,
                description:    draft.description,
                attending:      []
            )

            promise(Result.success(newEvent))
        }
    }

    static func getMyEvents() -> Future<[Event], Error> {
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

    static func getEvents(eventIDs: [String]) -> Future<[Event], Error> {
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

    static func joinEvent(_ eventID: String) -> Future<Bool, Error> {
        Future { promise in
            Task {
                guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

                let eventRef = firestore.collection(DatabaseKey.event).document(eventID)

                eventRef.updateData([Event.DatabaseKey.attending: FieldValue.arrayUnion([currentUserID])])
            }
        }
    }

    static func getProfilesOfAttending(userIDs: [String]) -> Future<[Profile], Error> {
        Future { promise in
            guard !userIDs.isEmpty else {
                promise(Result.success([]))
                return
            }

            firestore
                .collection(DatabaseKey.profile)
                .whereField(Profile.DatabaseKey.userID, in: userIDs)
                .getDocuments { querySnapshot, err in
                    guard let querySnapshot = querySnapshot else {
                        promise(Result.failure(Failure.unknown))
                        return
                    }
                    let profiles: [Profile] = querySnapshot.documents.compactMap { document in
                        try? document.data(as: Profile.self)
                    }
                    promise(Result.success(profiles))
                }
        }
    }
}

extension FirebaseHandler {
    private static func runTransaction(
        _ action: @escaping (Transaction, ErrorPointer) throws -> ()
    ) -> Future<Bool, Error> {
        Future { promise in
            Task {
                var errorToThrow: Error?
                let _ = try await firestore.runTransaction { transaction, errorPointer in
                    do { try action(transaction, errorPointer) } catch { errorToThrow = error }
                    return nil
                }
                if let errorToThrow { promise(.failure(errorToThrow)) }
                promise(.success(true))
            }
        }
    }

    private static func experiment() -> Future<Bool, Error> {
        Future { promise in
            Task { let _ = try await throwingThing() }
            promise(.success(true))
        }
    }

    private static func throwingThing() async throws -> Bool {
        if true {
            return true
        } else {
            throw Failure.signInNeeded
        }
    }
}
