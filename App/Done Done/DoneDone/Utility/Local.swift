//
//  Local.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine

enum Local {
    private static var emailKey = "email"
    private static var profileKey = "profile"

    static var email: String? {
        get {
            UserDefaults.standard.string(forKey: emailKey)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: emailKey)
        }
    }

    static var profile: Profile? {
        get {
            if let data = UserDefaults.standard.data(forKey: profileKey),
               let decodedProfile = try? JSONDecoder().decode(Profile.self, from: data) {
                return decodedProfile
            }
            return nil
        }

        set {
            if let encodedProfile = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedProfile, forKey: profileKey)
            }
        }
    }
}
