//
//  Logging.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/8/25.
//

enum Logging {
    case silent
    case terse
    case verbose

    static var mode: Logging = .silent
}

func log(_ message: String, level: Logging = .terse) {
    guard Logging.mode != .silent else { return }

    if level == .terse { print(message) }
    if level == .verbose && Logging.mode == .verbose { print(message) }
}
