//
//  Navigation.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/3/25.
//

import Combine

class Navigation: ObservableObject {
    enum State {
        case signIn
        case listEvents
        case createEvent
        case createGroup
    }

    @Published var current: State = .signIn
}
