//
//  RegistrarTests.swift
//  RegistrarTests
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import Testing
import Combine
import XCTest
@testable import Done_Done

struct DoneDoneTests {

    var cancellables = Set<AnyCancellable>()

    @Test func testAsync() async throws {
        let returnValue = try await asyncThing()
        #expect(returnValue == 500000500000)
    }

    @Test mutating func testFuture() async throws {
        let future = futureThing().receive(on: DispatchQueue.main).print()

        var valueReceived = false

        future.sink { completion in
            if completion != .finished { XCTFail() }
        } receiveValue: { value in
            valueReceived = true
        }.store(in: &cancellables)

        try await waitFor(condition: { valueReceived == true }, timeout: 20)
    }

    @Test func testWait() async throws {
        let start = DispatchTime.now()

        try await waitFor(condition: {
            return DispatchTime.now() > start + 4
        }, timeout: 5)
    }

        // MARK: - Test Utilities
    func asyncThing() async throws -> Int {
        let timeout: TimeInterval = 2
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        return 10
    }

    func futureThing() -> Future<Int, Failure> {
        Future { promise in
            Task {
                let value = try await asyncThing()
                promise(.success(value))
            }
        }
    }

    func waitFor(condition: () -> (Bool), timeout: TimeInterval = 10) async throws {
        let start = DispatchTime.now()
        let finish = start + timeout

        for _ in 0..<Int(timeout * 10_000_000_000) {
            if condition() {
                break
            }
            if DispatchTime.now() > finish {
                throw Failure.testFailure
            }
            try? await Task.sleep(nanoseconds: UInt64(1))
        }
    }

    enum Failure: Error {
        case testFailure
    }
}
