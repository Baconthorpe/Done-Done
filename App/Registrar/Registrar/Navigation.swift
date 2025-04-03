//
//  Navigation.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/3/25.
//

enum Navigation {
    case signIn
    case listEvents

    static var current: Navigation = .signIn
}

func navigate(to destination: Navigation) {
    Navigation.current = destination
}
