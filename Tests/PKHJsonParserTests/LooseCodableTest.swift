//
//  Untitled.swift
//  PKHJsonParser
//
//  Created by 박길호(팀원) - 서비스개발담당App개발팀 on 7/18/25.
//

import Testing
import Foundation
@testable import PKHJsonParser

// MARK: - Test Suite
@Suite("커스텀 프로퍼티 래퍼 Codable 테스트")
struct PropertyWrapperCodableTests {

    let decoder = JSONDecoder()

        func decode<T: Decodable>(json: String) throws -> T {
            let data = json.data(using: .utf8)!
            return try decoder.decode(T.self, from: data)
        }

        @Test("@LooseBool 동작 테스트")
        func testLooseBool() throws {
            struct TestModel: Codable { @LooseBool var value: Bool }
            #expect((try decode(json: #"{"value": true}"#) as TestModel).value == true)
            #expect((try decode(json: #"{"value": "y"}"#) as TestModel).value == true)
            #expect((try decode(json: #"{"value": 1}"#) as TestModel).value == true)
            #expect((try decode(json: #"{"value": false}"#) as TestModel).value == false)
            #expect((try decode(json: #"{"value": "no"}"#) as TestModel).value == false)
            #expect((try decode(json: #"{"value": 0}"#) as TestModel).value == false)
        }

        @Test("@LooseString 동작 테스트")
        func testLooseString() throws {
            struct TestModel: Codable { @LooseString var value: String }
            #expect((try decode(json: #"{"value": "hello world"}"#) as TestModel).value == "hello world")
            #expect((try decode(json: #"{"value": 12345}"#) as TestModel).value == "12345")
            #expect((try decode(json: #"{"value": 99.99}"#) as TestModel).value == "99.99")
            #expect((try decode(json: #"{"value": true}"#) as TestModel).value == "true")
        }

        @Test("@LooseInt 동작 테스트")
        func testLooseInt() throws {
            struct TestModel: Codable { @LooseInt var value: Int }
            #expect((try decode(json: #"{"value": 777}"#) as TestModel).value == 777)
            #expect((try decode(json: #"{"value": "123"}"#) as TestModel).value == 123)
            #expect((try decode(json: #"{"value": 55.5}"#) as TestModel).value == 55)
            #expect((try decode(json: #"{"value": "not_a_number"}"#) as TestModel).value == 0)
        }

        @Test("@LooseDouble 동작 테스트")
        func testLooseDouble() throws {
            struct TestModel: Codable { @LooseDouble var value: Double }
            #expect((try decode(json: #"{"value": 123.45}"#) as TestModel).value == 123.45)
            #expect((try decode(json: #"{"value": "67.89"}"#) as TestModel).value == 67.89)
            #expect((try decode(json: #"{"value": 100}"#) as TestModel).value == 100.0)
            #expect((try decode(json: #"{"value": "string"}"#) as TestModel).value == 0.0)
        }
}
