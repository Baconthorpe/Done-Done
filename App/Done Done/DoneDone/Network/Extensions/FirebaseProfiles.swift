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

            var formattedDraft = draft.asDictionary()
            formattedDraft[Profile.DatabaseKey.userID] = currentUserID

            firestore.collection(DatabaseKey.profile).document(currentUserID).setData(formattedDraft) { error in
                if let error = error {
                    promise(Result.failure(Failure.firebase(error)))
                    return
                }

                let newProfile = Profile(
                    userID: currentUserID,
                    name: draft.name,
                    tagline: draft.tagline,
                    icon: draft.icon,
                    userTeam: currentUserID,
                    memberTeams: draft.memberTeams,
                    leaderTeams: draft.leaderTeams
                )

                promise(Result.success(newProfile))
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
