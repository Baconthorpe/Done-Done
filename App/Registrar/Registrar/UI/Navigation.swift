//
//  Navigation.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/3/25.
//

import Combine

class Navigation: ObservableObject {
    enum Location {
        case signedOut
        case signedIn(withProfile: Bool)
    }

    enum Flow {
        case creatingEvent
        case creatingGroup
    }

    @Published var location: Location = .signedOut
}
