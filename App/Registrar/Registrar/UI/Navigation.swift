//
//  Navigation.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/3/25.
//

import Combine

class Navigation: ObservableObject {
    enum Location {
        case signIn
        case createProfile
        case listEvents
        case createGroup
    }

    enum Flow {
        case goBack
        case signedOut
        case signedIn(profile: Profile?)
        case profileCreated
        case groupCreated
        case eventCreated
    }

    @Published var location: Location = .signIn {
        didSet {
            if location == locationStack.last {
                locationStack.removeLast()
            } else {
                locationStack.append(location)
            }
        }
    }

    private var locationStack: [Location] = []

    func flow(_ flow: Flow) {
        switch flow {
        case .goBack:                   location = locationStack.last ?? .signIn
        case .signedOut:                location = .signIn
        case let.signedIn(profile):     location = (profile != nil) ? .listEvents : .createProfile
        case .profileCreated,
                .groupCreated,
                .eventCreated:          location = .listEvents
        }
    }
}
