//
//  Local.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine

enum Local {
    private static var emailKey = "email"
    static var email: String? {
        get {
            UserDefaults.standard.string(forKey: emailKey)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: emailKey)
        }
    }
}
