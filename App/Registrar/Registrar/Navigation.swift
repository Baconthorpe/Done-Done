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
    }

    @Published var current: State = .signIn
}

//enum Navigation {
//    case signIn
//    case listEvents
//    case createEvent
//
//    @Published static var current: Navigation = .signIn
//}

//func navigate(to destination: Navigation.State) {
//    Navigation.current = destination
//}
