//
//  FirebaseHandler.swift
//  Done Done
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
        static let team = "teams"
        static let ticket = "tickets"
        static let event = "events"
        static let eventInvitation = "eventInvitations"
        static let group = "groups"
        static let teamInvitation = "teamInvitations"
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
}
