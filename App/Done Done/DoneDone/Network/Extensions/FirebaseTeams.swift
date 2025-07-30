//
//  FirebaseTeams.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 6/13/25.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

// MARK: - Team Methods
extension FirebaseHandler {
    static func createTeam(_ draft: Team.Draft, profile: Profile) -> Future<Team, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            firestore.runTransaction { transaction, errorPointer in
                var formattedDraft = draft.asDictionary()
                formattedDraft[Team.DatabaseKey.members] = [currentUserID]
                formattedDraft[Team.DatabaseKey.leaders] = [currentUserID]

                let newTeamRef = firestore.collection(DatabaseKey.group).document()

                let profile = firestore
                    .collection(DatabaseKey.profile)
                    .document(currentUserID)

                transaction.setData(formattedDraft, forDocument: newTeamRef)
                transaction.updateData([
                    Profile.DatabaseKey.memberTeams: FieldValue.arrayUnion([newTeamRef.documentID]),
                    Profile.DatabaseKey.leaderTeams: FieldValue.arrayUnion([newTeamRef.documentID])
                ], forDocument: profile)

                let newTeam = Team(
                    name: newTeamRef.documentID,
                    description: draft.description,
                    members: [currentUserID],
                    leaders: [currentUserID],
                    tickets: []
                )

                return newTeam

            } completion: { newTeam, error in
                if let error = error {
                    promise(.failure(Failure.firebase(error)))
                    return
                }
                guard let newTeam = newTeam as? Team else {
                    promise(.failure(Failure.unknown))
                    return
                }

                promise(.success(newTeam))
            }
        }
    }

    static func sendTeamInvitation(_ draft: TeamInvitation.Draft) -> Future<TeamInvitation, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            var formattedDraft = draft.asDictionary()
            formattedDraft[TeamInvitation.DatabaseKey.sender] = currentUserID

            let newTeamInvitationRef = firestore.collection(DatabaseKey.teamInvitation).addDocument(data: formattedDraft) { error in
                if let error = error {
                    promise(Result.failure(Failure.firebase(error)))
                    return
                }
            }

            let newTeamInvitation = TeamInvitation(
                id: newTeamInvitationRef.documentID,
                team: draft.team,
                sender: currentUserID,
                recipient: draft.recipient,
                info: TeamInvitation.Info(
                    teamName: draft.teamName,
                    senderName: draft.senderName
                )
            )

            promise(Result.success(newTeamInvitation))
        }
    }

    static func getMyTeamInvitations() -> Future<[TeamInvitation], Error> {
            Future { promise in
                guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }
    
                firestore
                    .collection(DatabaseKey.teamInvitation)
                    .whereField(TeamInvitation.DatabaseKey.recipient, isEqualTo: currentUserID)
                    .getDocuments { querySnapshot, err in
                        guard let querySnapshot = querySnapshot else {
                            promise(Result.failure(Failure.unknown))
                            return
                        }
                        let teamInvitations: [TeamInvitation] = querySnapshot.documents.compactMap { document in
                            try? document.data(as: TeamInvitation.self)
                        }
                        promise(Result.success(teamInvitations))
                    }
            }
        }

    static func acceptTeamInvitation(_ invitation: TeamInvitation) -> Future<Void, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }
            guard invitation.recipient == currentUserID else { promise(Result.failure(Failure.actionNotAllowed)); return }
            guard let invitationID = invitation.id else { promise(Result.failure(Failure.unknown)); return }

            let teamRef = firestore.collection(DatabaseKey.team).document(invitation.team)
            let profileRef = firestore.collection(DatabaseKey.profile).document(currentUserID)
            let invitationRef = firestore.collection(DatabaseKey.teamInvitation).document(invitationID)

            firestore.runTransaction { transaction, errorPointer in
                transaction.updateData(
                    [Team.DatabaseKey.members: FieldValue.arrayUnion([currentUserID])],
                    forDocument: teamRef
                )
                transaction.updateData(
                    [Profile.DatabaseKey.memberTeams: FieldValue.arrayUnion([invitation.team])],
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

    static func declineTeamInvitation(_ invitation: TeamInvitation) -> Future<Void, Error> {
        Future { promise in
            let teamRef = firestore.collection(DatabaseKey.team).document(invitation.team)

            teamRef.delete { error in
                if let error = error {
                    promise(.failure(Failure.firebase(error)))
                    return
                }

                promise(.success(()))
            }
        }
    }

    static func leaveTeam(_ teamID: String) -> Future<Void, Error> {
        Future { promise in
            guard let currentUserID = currentUser?.uid else { promise(Result.failure(Failure.signInNeeded)); return }

            let groupRef = firestore.collection(DatabaseKey.team).document(teamID)
            let profileRef = firestore.collection(DatabaseKey.profile).document(currentUserID)

            firestore.runTransaction { transaction, errorPointer in
                transaction.updateData(
                    [Team.DatabaseKey.members: FieldValue.arrayRemove([currentUserID])],
                    forDocument: groupRef
                )
                transaction.updateData(
                    [Profile.DatabaseKey.memberTeams: FieldValue.arrayRemove([teamID]),
                     Profile.DatabaseKey.leaderTeams: FieldValue.arrayRemove([teamID])],
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

    static func getTeams(teamIDs: [String]) -> Future<[Team], Error> {
        Future { promise in
            guard !teamIDs.isEmpty else {
                promise(Result.success([]))
                return
            }

            firestore
                .collection(DatabaseKey.team)
                .whereField(FieldPath.documentID(), in: teamIDs)
                .getDocuments { querySnapshot, err in
                    guard let querySnapshot = querySnapshot else {
                        promise(Result.failure(Failure.unknown))
                        return
                    }
                    let teams: [Team] = querySnapshot.documents.compactMap { document in
                        try? document.data(as: Team.self)
                    }
                    promise(Result.success(teams))
                }
        }
    }

    static func getTeamLeaders(_ team: Team) -> Future<[Profile], Error> {
        Future { promise in
            firestore
                .collection(DatabaseKey.profile)
                .whereField(Profile.DatabaseKey.userID, in: team.leaders)
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

    static func getTeamMembers(_ team: Team) -> Future<[Profile], Error> {
        Future { promise in
            firestore
                .collection(DatabaseKey.profile)
                .whereField(Profile.DatabaseKey.userID, in: team.members)
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
