//
//  PublisherExtensions.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/16/24.
//

import Combine

extension Publisher {
    func asFuture() -> Future<Output, Failure> {
        var _: AnyCancellable?
        return Future<Output, Failure> { promise in
            _ = self.sink { completion in
                if case .failure(let error) = completion {
                    promise(.failure(error))
                }
            } receiveValue: { value in
                promise(.success(value))
            }
        }
    }
}


extension Future {
    func onValue(perform action: @escaping (Output) -> Void) -> Future<Output, Failure> {
        map { action($0); return $0 }.asFuture()
    }
}
