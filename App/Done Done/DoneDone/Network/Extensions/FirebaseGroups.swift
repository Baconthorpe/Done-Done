//
//  FirebaseGroups.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/28/25.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

// MARK: - Group Methods
extension FirebaseHandler {
    static func createGroup(_ draft: Group.Draft, profile: Profile) -> Future<Group, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            firestore.runTransaction { transaction, errorPointer in
                var formattedDraft = draft.asDictionary()
                formattedDraft[Group.DatabaseKey.members] = [currentUserID]
                formattedDraft[Group.DatabaseKey.organizers] = [currentUserID]

                let newGroupRef = firestore.collection(DatabaseKey.group).document()

                let profile = firestore
                    .collection(DatabaseKey.profile)
                    .document(currentUserID)

                transaction.setData(formattedDraft, forDocument: newGroupRef)
                transaction.updateData([
                    Profile.DatabaseKey.memberGroups: FieldValue.arrayUnion([newGroupRef.documentID]),
                    Profile.DatabaseKey.organizerGroups: FieldValue.arrayUnion([newGroupRef.documentID])
                ], forDocument: profile)

                let newGroup = Group(
                    id:             newGroupRef.documentID,
                    name:           draft.name,
                    description:    draft.description,
                    members:        [currentUserID],
                    organizers:     [currentUserID],
                    events:         []
                )
                return newGroup

            } completion: { newGroup, error in
                guard let newGroup = newGroup as? Group else {
                    promise(.failure(Failure.unknown))
                    return
                }
                if let error = error {
                    promise(.failure(Failure.firebase(error)))
                    return
                }

                promise(.success(newGroup))
            }
        }
    }

    static func sendGroupInvitation(_ draft: GroupInvitation.Draft) -> Future<GroupInvitation, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            var formattedDraft = draft.asDictionary()
            formattedDraft[GroupInvitation.DatabaseKey.sender] = currentUserID

            let newGroupInvitationRef = firestore.collection(DatabaseKey.groupInvitation).addDocument(data: formattedDraft) { error in
                if let error = error {
                    promise(Result.failure(Failure.firebase(error)))
                    return
                }
            }

            let newGroupInvitation = GroupInvitation(
                id: newGroupInvitationRef.documentID,
                group: draft.group,
                sender: currentUserID,
                senderName: draft.senderName,
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
            guard let invitationID = invitation.id else { promise(Result.failure(Failure.unknown)); return }

            let groupRef = firestore.collection(DatabaseKey.group).document(invitation.group)
            let profileRef = firestore.collection(DatabaseKey.profile).document(currentUserID)
            let invitationRef = firestore.collection(DatabaseKey.groupInvitation).document(invitationID)

            firestore.runTransaction { transaction, errorPointer in
                transaction.updateData(
                    [Group.DatabaseKey.members: FieldValue.arrayUnion([currentUserID])],
                    forDocument: groupRef
                )
                transaction.updateData(
                    [Profile.DatabaseKey.memberGroups: FieldValue.arrayUnion([invitation.group])],
                    forDocument: profileRef
                )
                transaction.deleteDocument(invitationRef)
                return
            } completion: { _, error in
                if let error = error {
                    promise(.failure(Failure.firebase(error)))
                    return
                }

                promise(.success(()))
            }
        }
    }

    static func declineGroupInvitation(_ invitation: GroupInvitation) -> Future<Void, Error> {
        Future { promise in
            let groupRef = firestore.collection(DatabaseKey.group).document(invitation.group)

            groupRef.delete { error in
                if let error = error {
                    promise(.failure(Failure.firebase(error)))
                    return
                }

                promise(.success(()))
            }
        }
    }

    static func leaveGroup(_ groupID: String) -> Future<Void, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }
            
            let groupRef = firestore.collection(DatabaseKey.group).document(groupID)
            let profileRef = firestore.collection(DatabaseKey.profile).document(currentUserID)

            firestore.runTransaction { transaction, errorPointer in
                transaction.updateData(
                    [Group.DatabaseKey.members: FieldValue.arrayRemove([currentUserID])],
                    forDocument: groupRef
                )
                transaction.updateData(
                    [Profile.DatabaseKey.memberGroups: FieldValue.arrayRemove([groupID]),
                     Profile.DatabaseKey.organizerGroups: FieldValue.arrayRemove([groupID])],
                    forDocument: profileRef
                )
                return
            } completion: { _, error in
                if let error = error {
                    promise(.failure(Failure.firebase(error)))
                    return
                }

                promise(.success(()))
            }
        }
    }

    static func getGroups(groupIDs: [String]) -> Future<[Group], Error> {
        Future { promise in
            guard !groupIDs.isEmpty else {
                promise(Result.success([]))
                return
            }

            firestore
                .collection(DatabaseKey.group)
                .whereField(FieldPath.documentID(), in: groupIDs)
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

    static func getGroupOrganizers(_ group: Group) -> Future<[Profile], Error> {
        Future { promise in
            firestore
                .collection(DatabaseKey.profile)
                .whereField(Profile.DatabaseKey.userID, in: group.organizers)
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

    static func getGroupMembers(_ group: Group) -> Future<[Profile], Error> {
        Future { promise in
            firestore
                .collection(DatabaseKey.profile)
                .whereField(Profile.DatabaseKey.userID, in: group.members)
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
