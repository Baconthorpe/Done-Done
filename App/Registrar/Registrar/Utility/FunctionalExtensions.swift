//
//  PublisherExtensions.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/16/24.
//

import Combine
import SwiftUI

extension Publisher {
    func sinkValue(_ binding: Binding<Output>, logPrefix: String = "Publisher") -> AnyCancellable {
        sinkCompletion(logPrefix: logPrefix) { binding.wrappedValue = $0 }
    }

    func sinkCompletion(logPrefix: String = "Publisher", _ completion: @escaping (Output) -> Void) -> AnyCancellable {
        sink { completion in
            if case let .failure(error) = completion {
                log("\(logPrefix) failed with error: \(error)")
            }
        } receiveValue: { output in
            log("\(logPrefix) succeeded with value: \(output)", level: .verbose)
            completion(output)
        }
    }

    func sideEffect(_ body: @escaping (Output) -> Void) -> Publishers.Map<Self, Output> {
        map { body($0); return $0 }
    }
}
