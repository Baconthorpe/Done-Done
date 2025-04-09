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

    func futureMap<O>(_ transform: @escaping (Output) -> O) -> Future<O, Failure> {
        map(transform).asFuture()
    }

    func futureFlatMap<P: Publisher>(_ transform: @escaping (Output) -> P) -> Future<P.Output, Failure>
    where Failure == P.Failure {
        flatMap(transform).asFuture()
    }

//    func boop() {
//        let a = map(
//    }
}
