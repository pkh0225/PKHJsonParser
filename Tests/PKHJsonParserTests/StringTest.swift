//
//  StringTest.swift
//  PKHJsonParser
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2/7/25.
//

import Testing
@testable import PKHJsonParser

struct StringTest {
    @Test func isValid() async throws {
        #expect("1".isValid)
        ["", "null", "(null)", "nil", "   "].forEach { #expect($0.isValid == false) }
    }
    @Test func trim() async throws {
        #expect(" 123".trim() == "123")
        #expect("123 ".trim() == "123")
        #expect(" 123 ".trim() == "123")
        #expect("1 2 3".trim() == "1 2 3")
    }
    @Test func contains() async throws {
        #expect("hello world".contains("world"))
        #expect("hello".contains("x") == false)
    }

    @Test func replace() async throws {
        #expect("hello world".replace("world", "Swift") == "hello Swift")
        #expect("foo bar foo".replace("foo", "baz") == "baz bar baz")
    }

    @Test func toInt() async throws {
        #expect("123".toInt() == 123)
        #expect("abc".toInt() == 0)
    }

    @Test func toDouble() async throws {
        #expect("123.45".toDouble() == 123.45)
        #expect("xyz".toDouble() == 0)
    }

    @Test func toBool() async throws {
        #expect("true".toBool() == true)
        #expect("yes".toBool() == true)
        #expect("y".toBool() == true)
        #expect("false".toBool() == false)
        #expect("no".toBool() == false)
    }

    @Test func toDictionary() async throws {
        #expect("{\"key\":\"value\"}".toDictionary()?["key"] as? String == "value")
        #expect("invalid json".toDictionary() == nil)
    }
}
