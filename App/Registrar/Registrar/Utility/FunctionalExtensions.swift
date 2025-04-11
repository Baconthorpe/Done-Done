//
//  PublisherExtensions.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/16/24.
//

import Combine

extension Publisher {
    func sinkValue(_ body: @escaping (Output) -> Void) -> AnyCancellable {
        sink { completion in
            if case let .failure(error) = completion {
                log("Error: \(error)")
            }
        } receiveValue: { output in
            body(output)
        }
    }

    func sideEffect(_ body: @escaping (Output) -> Void) -> Publishers.Map<Self, Output> {
        map { body($0); return $0 }
    }
}
