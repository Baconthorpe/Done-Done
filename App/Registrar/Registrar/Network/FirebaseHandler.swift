//
//  FirebaseHandler.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

enum FirebaseHandler {
    enum Failure: Error {
        case unknown
        case signInNeeded
        case actionNotAllowed
        case firebase(Error)
    }

    struct DatabaseKey {
        private init() {}

        static let profile = "profiles"
        static let event = "events"
        static let group = "groups"
        static let groupInvitation = "groupInvitations"
    }

    static var firestore: Firestore!
    static var currentUser: User? {
        Auth.auth().currentUser
    }
    static var userIsAnonymous: Bool {
        currentUser?.isAnonymous ?? false
    }

    static var actionCodeSettings = {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://www.example.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        return actionCodeSettings
    }()

    static func startUp() {
        FirebaseApp.configure()
        firestore = Firestore.firestore()
    }

    // MARK: - Sign In
    static func signInWithGoogle() -> Future<Void, Error> {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            return refreshSignInWithGoogle()
        } else {
            return initiateFreshSignInWithGoogle()
        }
    }

    private static func refreshSignInWithGoogle() -> Future<Void, Error> {
        Future { promise in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    promise(Result.failure(Failure.firebase(error)))
                    return
                }
                guard user != nil else {
                    promise(Result.failure(Failure.unknown))
                    return
                }

                promise(Result.success(()))
            }
        }
    }

    private static func initiateFreshSignInWithGoogle() -> Future<Void, Error> {
        Future { promise in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController,
                  let clientID = FirebaseApp.app()?.options.clientID
            else {
                promise(Result.failure(Failure.unknown))
                return
            }

            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                guard error == nil,
                      let user = result?.user,
                      let idToken = user.idToken?.tokenString
                else {
                    promise(Result.failure(Failure.unknown))
                    return
                }

                let signInCredential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                 accessToken: user.accessToken.tokenString)
                completeSignIn(with: signInCredential, promise: promise)
            }
        }
    }

    private static func completeSignIn(with credential: AuthCredential,
                                       promise: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                promise(Result.failure(Failure.firebase(error)))
                return
            }
            promise(Result.success(()))
        }
    }

    static func signIn(email: String) -> Future<String, Error> {
        Future { promise in
            Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
                if let error = error {
                    promise(Result.failure(error))
                    return
                }
                promise(Result.success(email))
            }
        }
    }

    static func signInAnonymously() -> Future<Void, Error> {
        Future { promise in
            Auth.auth().signInAnonymously() { authResult, error in
                if let error = error {
                    promise(Result.failure(error))
                    return
                }
                promise(Result.success(()))
            }
        }
    }

    // MARK: - Profiles
    static func getProfile() -> Future<Profile?, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            firestore
                .collection(DatabaseKey.profile)
                .whereField(Profile.DatabaseKey.userID, isEqualTo: currentUserID)
                .getDocuments { querySnapshot, err in
                    guard let querySnapshot = querySnapshot else {
                        promise(Result.failure(Failure.unknown))
                        return
                    }
                    let profiles: [Profile] = querySnapshot.documents.compactMap { document in
                        try? document.data(as: Profile.self)
                    }
                    guard let profile = profiles.first else {
                        promise(Result.success(nil))
                        return
                    }
                    promise(Result.success(profile))
                }
        }
    }

    static func createProfile(_ draft: Profile.Draft) -> Future<Profile, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            var formattedDraft = draft.asDictionary()
            formattedDraft[Profile.DatabaseKey.userID] = currentUserID

            let newProfileRef = firestore.collection(DatabaseKey.profile).addDocument(data: formattedDraft) { error in
                if let error = error {
                    promise(Result.failure(error))
                    return
                }
            }

            let newProfile = Profile(
                id:                 newProfileRef.documentID,
                userID:             currentUserID,
                name:               draft.name,
                memberGroups:       draft.memberGroups,
                organizerGroups:    draft.organizerGroups,
                attendingEvents:    draft.attendingEvents
            )

            promise(Result.success(newProfile))
        }
    }

    // MARK: - Groups
    static func createGroup(_ draft: Group.Draft) -> Future<Group, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }
            
            var formattedDraft = draft.asDictionary()
            formattedDraft[Group.DatabaseKey.members] = [currentUserID]
            formattedDraft[Group.DatabaseKey.organizers] = [currentUserID]

            let newGroupRef = firestore.collection(DatabaseKey.group).addDocument(data: formattedDraft) { error in
                if let error = error {
                    promise(Result.failure(error))
                    return
                }
            }

            let newGroup = Group(
                id:             newGroupRef.documentID,
                name:           draft.name,
                description:    draft.description,
                members:        [currentUserID],
                organizers:     [currentUserID],
                events:         []
            )

            promise(Result.success(newGroup))
        }
    }

    static func sendGroupInvitation(_ draft: GroupInvitation.Draft) -> Future<GroupInvitation, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            var formattedDraft = draft.asDictionary()
            formattedDraft[GroupInvitation.DatabaseKey.sender] = currentUserID

            let newGroupInvitationRef = firestore.collection(DatabaseKey.groupInvitation).addDocument(data: formattedDraft) { error in
                if let error = error {
                    promise(Result.failure(error))
                    return
                }
            }

            let newGroupInvitation = GroupInvitation(
                id: newGroupInvitationRef.documentID,
                group: draft.group,
                sender: currentUserID,
                recipient: draft.recipient
            )

            promise(Result.success(newGroupInvitation))
        }
    }

    static func getMyGroupInvitations() -> Future<[GroupInvitation], Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            firestore
                .collection(DatabaseKey.groupInvitation)
                .whereField(GroupInvitation.DatabaseKey.recipient, isEqualTo: currentUserID)
                .getDocuments { querySnapshot, err in
                    guard let querySnapshot = querySnapshot else {
                        promise(Result.failure(Failure.unknown))
                        return
                    }
                    let groupInvitations: [GroupInvitation] = querySnapshot.documents.compactMap { document in
                        try? document.data(as: GroupInvitation.self)
                    }
                    promise(Result.success(groupInvitations))
                }
        }
    }

    static func acceptGroupInvitation(_ invitation: GroupInvitation) -> Future<Void, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }
            guard invitation.recipient == currentUserID else { promise(Result.failure(Failure.actionNotAllowed)); return }

            let groupRef = firestore.collection(DatabaseKey.group).document(invitation.group)

            Task {
                do {
                    try await groupRef.updateData([Group.DatabaseKey.members: FieldValue.arrayUnion([currentUserID])])
                    promise(Result.success(()))
                } catch {
                    promise(Result.failure(Failure.firebase(error)))
                }
            }
        }
    }

    static func getGroups(groupIDs: [String]) -> Future<[Group], Error> {
        Future { promise in
            firestore
                .collection(DatabaseKey.group)
                .whereField(Group.DatabaseKey.id, in: groupIDs)
                .getDocuments { querySnapshot, err in
                    guard let querySnapshot = querySnapshot else {
                        promise(Result.failure(Failure.unknown))
                        return
                    }
                    let groups: [Group] = querySnapshot.documents.compactMap { document in
                        try? document.data(as: Group.self)
                    }
                    promise(Result.success(groups))
                }
        }
    }

    // MARK: - Events
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
                .whereField(Event.DatabaseKey.id, in: eventIDs)
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
