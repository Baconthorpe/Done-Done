//
//  Navigation.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/3/25.
//

import Combine
import SwiftUI

class Flow: ObservableObject {
    enum Location {
        case signedOut
        case signedIn(withProfile: Bool)
    }

    enum Go {
        case creatingTicket
        case creatingTeam
    }

    @Published var path = NavigationPath()
    @Published var location: Location = .signedOut
}
