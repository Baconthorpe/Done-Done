//
//  Provide.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Foundation
import Combine

enum Provide {
    enum Failure: Error {
        case actionRequiresProfile
        case actionRequiresEventID
        case actionRequiresGroupID
    }
}
