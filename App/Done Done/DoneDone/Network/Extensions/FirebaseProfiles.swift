//
//  FirebaseProfiles.swift
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

// MARK: - Profile Methods
extension FirebaseHandler {
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

            var formattedProfileDraft = draft.asDictionary()
            formattedProfileDraft[Profile.DatabaseKey.userID] = currentUserID
            var formattedTeamDraft = Team.Draft(name: draft.name, description: "user team").asDictionary()


            firestore.runTransaction { transaction, errorPointer in
                transaction.setData(formattedProfileDraft, forDocument: firestore.collection(DatabaseKey.profile).document(currentUserID))
                transaction.setData(formattedTeamDraft, forDocument: firestore.collection(DatabaseKey.team).document(currentUserID))

                return Profile(
                    userID: currentUserID,
                    name: draft.name,
                    tagline: draft.tagline,
                    icon: draft.icon,
                    userTeam: currentUserID,
                    memberTeams: draft.memberTeams,
                    leaderTeams: draft.leaderTeams
                )
            } completion: { profile, error in
                if let error = error {
                    promise(.failure(Failure.firebase(error)))
                    return
                }
                guard let profile = profile as? Profile else {
                    promise(.failure(Failure.unknown))
                    return
                }

                promise(.success(profile))
            }
        }
    }

    static func getProfilesByName(_ name: String) -> Future<[Profile], Error> {
        Future { promise in
            firestore.collection(DatabaseKey.profile)
                .whereField(Profile.DatabaseKey.name, isEqualTo: name)
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

//    static func getProfilesForGroups(_ groupIDs: [String]) -> Future<[Profile], Error> {
//        Future { promise in
//            firestore.collection(DatabaseKey.profile)
//                .whereField(Profile.DatabaseKey.memberGroups, in: groupIDs)
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
}
