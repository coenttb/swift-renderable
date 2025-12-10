//
//  Empty Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Foundation
import Testing
@testable import Rendering

@Suite
struct `Empty Tests` {

    // MARK: - Initialization

    @Test
    func `Empty can be instantiated`() {
        let empty = Rendering.Empty()
        _ = empty
        #expect(Bool(true))
    }

    @Test
    func `multiple Empty instances can be created`() {
        let empty1 = Rendering.Empty()
        let empty2 = Rendering.Empty()
        _ = (empty1, empty2)
        #expect(Bool(true))
    }

    // MARK: - Equatable

    @Test
    func `Empty is Equatable`() {
        let empty1 = Rendering.Empty()
        let empty2 = Rendering.Empty()
        #expect(empty1 == empty2)
    }

    @Test
    func `all Empty instances are equal`() {
        let empties = (0..<10).map { _ in Rendering.Empty() }
        for i in 0..<empties.count {
            for j in 0..<empties.count {
                #expect(empties[i] == empties[j])
            }
        }
    }

    // MARK: - Hashable

    @Test
    func `Empty is Hashable`() {
        let empty = Rendering.Empty()
        let hash = empty.hashValue
        _ = hash
        #expect(Bool(true))
    }

    @Test
    func `Empty instances have same hash`() {
        let empty1 = Rendering.Empty()
        let empty2 = Rendering.Empty()
        #expect(empty1.hashValue == empty2.hashValue)
    }

    @Test
    func `Empty can be used in Set`() {
        var set: Set<Rendering.Empty> = []
        set.insert(Rendering.Empty())
        set.insert(Rendering.Empty())

        #expect(set.count == 1)
    }

    @Test
    func `Empty can be used as Dictionary key`() {
        var dict: [Rendering.Empty: String] = [:]
        dict[Rendering.Empty()] = "first"
        dict[Rendering.Empty()] = "second"

        #expect(dict.count == 1)
        #expect(dict[Rendering.Empty()] == "second")
    }

    // MARK: - Sendable

    @Test
    func `Empty is Sendable`() {
        let empty = Rendering.Empty()
        Task {
            _ = empty
        }
        #expect(Bool(true))
    }

    @Test
    func `Empty can be passed across actor boundaries`() async {
        let empty = Rendering.Empty()
        await Task.detached {
            _ = empty
        }.value
        #expect(Bool(true))
    }

    // MARK: - Codable

    @Test
    func `Empty is Codable`() throws {
        let original = Rendering.Empty()

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Rendering.Empty.self, from: data)

        #expect(original == decoded)
    }

    @Test
    func `Empty encodes to minimal JSON`() throws {
        let empty = Rendering.Empty()
        let encoder = JSONEncoder()
        let data = try encoder.encode(empty)
        let json = String(decoding: data, as: UTF8.self)

        // Empty struct should encode to empty object or similar minimal representation
        #expect(json == "{}")
    }

    // MARK: - Typealias

    @Test
    func `Empty typealias works`() {
        let empty: Empty = Empty()
        #expect(empty == Rendering.Empty())
    }

    // MARK: - Usage Patterns

    @Test
    func `Empty can be stored in array`() {
        let empties: [Rendering.Empty] = [
            Rendering.Empty(),
            Rendering.Empty(),
            Rendering.Empty()
        ]
        #expect(empties.count == 3)
    }

    @Test
    func `Empty can be optional`() {
        let maybeEmpty: Rendering.Empty? = Rendering.Empty()
        #expect(maybeEmpty != nil)

        let noEmpty: Rendering.Empty? = nil
        #expect(noEmpty == nil)
    }
}
