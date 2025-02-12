//
//  StringTest.swift
//  PKHJsonParser
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2/7/25.
//

import Testing
import Foundation
@testable import PKHJsonParser

struct StringTest {
    func isValidTrue(string: String) async throws {
        #expect("123".isValid)
    }
    @Test(arguments: [
        "",
        "null",
        "(null)",
        "nil", 
        "   "
    ]) func isValidFalse(string: String) async throws {
        #expect(string.isValid == false)
    }
    @Test(arguments: [
        " 123",
        "123 ",
        " 123 ",
    ]) func trim(string: String) async throws {
        #expect(string.trim() == "123")
    }

    func trim2(string: String) async throws {
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

    struct testDictionary {
        @Test func toDictionaryArray() async throws {
            do {
                let json  = """
                        {
                            "key": ["축구", "독서", "코딩"]
                        }
                        """
                let array = json.toDictionary()?["key"] as? [String]
                #expect(array?.count == 3)
                #expect(array?[0] == "축구")
                #expect(array?[1] == "독서")
                #expect(array?[2] == "코딩")
            }
            do {
                let json  = """
                        {
                            "key": [11, 22, 33]
                        }
                        """
                let array = json.toDictionary()?["key"] as? [Int]
                #expect(array?.count == 3)
                #expect(array?[0] == 11)
                #expect(array?[1] == 22)
                #expect(array?[2] == 33)
            }
            do {
                let json  = """
                        {
                            "key": [11.1, 22.2, 33.3]
                        }
                        """
                let array = json.toDictionary()?["key"] as? [CGFloat]
                #expect(array?.count == 3)
                #expect(array?[0] == 11.1)
                #expect(array?[1] == 22.2)
                #expect(array?[2] == 33.3)
            }

            do {
                let json  = """
                        {
                            "key": [
                                    {
                                        "city": "서울1",
                                        "zip": 12
                                    },
                                    {
                                        "city": "서울2",
                                        "zip": 123
                                    },
                                    {
                                        "city": "서울3",
                                        "zip": 1234
                                    }
                                ]
                        }
                        """
                let array = json.toDictionary()?["key"] as? [[String: Any]]
                #expect(array?.count == 3)
                #expect(array?[0]["city"]  as? String == "서울1")
                #expect(array?[0]["zip"]  as? Int == 12)

                #expect(array?[1]["city"]  as? String == "서울2")
                #expect(array?[1]["zip"]  as? Int == 123)

                #expect(array?[2]["city"]  as? String == "서울3")
                #expect(array?[2]["zip"]  as? Int == 1234)
            }
        }

        @Test func toDictionarySubClass() async throws {
            let json = """
                    {
                        "key": {
                            "city": "서울",
                            "zip": 12345
                        }
                    }
                    """
            let dic = json.toDictionary()
            let subDic = dic?["key"] as? [String: Any]

            #expect(subDic?["city"] as? String == "서울")
            #expect(subDic?["zip"] as? Int == 12345)
        }

        @Test func toDictionaryBool() async throws {
            #expect("""
                    {
                        "key": true
                    }
                    """
                .toDictionary()?["key"] as? Bool == true)
            #expect("""
                    {
                        "key": false
                    }
                    """
                .toDictionary()?["key"] as? Bool == false)
        }

        @Test func toDictionaryCGFloat() async throws {
            #expect("""
                    {
                        "key": 123.0
                    }
                    """
                .toDictionary()?["key"] as? CGFloat == 123.0)
        }

        @Test func toDictionaryInt() async throws {
            #expect("""
                    {
                        "key": 123
                    }
                    """
                .toDictionary()?["key"] as? Int == 123)
        }

        @Test func toDictionaryString() async throws {
            #expect("""
                    {
                        "key": "string"
                    }
                    """
                .toDictionary()?["key"] as? String == "string")
        }

        @Test func toDictionaryNull() async throws {
            let json = """
                    {
                        "key": null
                    }
                    """
            let dic = json.toDictionary()

            #expect(dic?["key"] is NSNull)
        }

        @Test func toDictionaryNil() async throws {
            #expect("invalid json".toDictionary() == nil)
        }
    }

}
