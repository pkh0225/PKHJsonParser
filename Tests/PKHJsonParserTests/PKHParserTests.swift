import Testing
import Foundation
@testable import PKHJsonParser

// 커스텀 파서 객체 생성
class TestParserClass: PKHParser {
    var stringType: String = ""
    var intType: Int = 0
    var boolType: Bool = false
    var CGFloatType: CGFloat = 0
    var classType: TestParserSubClass?

    var arrayStringType: [String] = []
    var arrayIntType: [Int] = []
    var arrayCGFloatType: [CGFloat] = []
    var arraySubClassType: [TestParserSubClass] = []

    override func getDataMap() -> [ParserMap]? {
        return [
            ParserMap(ivar: "stringType", jsonKey: "username"),
            ParserMap(ivar: "intType", jsonKey: "user_age"),
            ParserMap(ivar: "boolType", jsonKey: "active_status")
        ]
    }
}

class TestParserSubClass: PKHParser {
    var stringType: String = ""
    var intType: Int = 0
    var boolType: Bool = false
}

struct PKHParserTests {
    struct ArrayTests {
        @Test func testSubClass() {
            let dic: [String: Any] = [
                "arraySubClassType": [
                    [ "stringType": "Alice1",
                      "intType": 1,
                      "boolType": true
                    ],
                    [ "stringType": "Alice2",
                      "intType": 2,
                      "boolType": false
                    ],
                    [ "stringType": "Alice3",
                      "intType": 3,
                      "boolType": true
                    ]
                ]
            ]

            let parser = TestParserClass(map: dic)

            #expect(parser.arraySubClassType.count == 3)
            #expect(parser.arraySubClassType[0].stringType == "Alice1")
            #expect(parser.arraySubClassType[0].intType == 1)
            #expect(parser.arraySubClassType[0].boolType == true)

            #expect(parser.arraySubClassType[1].stringType == "Alice2")
            #expect(parser.arraySubClassType[1].intType == 2)
            #expect(parser.arraySubClassType[1].boolType == false)

            #expect(parser.arraySubClassType[2].stringType == "Alice3")
            #expect(parser.arraySubClassType[2].intType == 3)
            #expect(parser.arraySubClassType[2].boolType == true)
        }

        @Test func testCGFloat() {
            let dic: [String: Any] = [
                "arrayCGFloatType": [1.1,2.2,3.3]
            ]

            let parser = TestParserClass(map: dic)

            #expect(parser.arrayCGFloatType.count == 3)
            #expect(parser.arrayCGFloatType[0] == 1.1)
            #expect(parser.arrayCGFloatType[1] == 2.2)
            #expect(parser.arrayCGFloatType[2] == 3.3)
        }

        @Test func testInt() {
            let dic: [String: Any] = [
                "arrayIntType": [1,2,3]
            ]

            let parser = TestParserClass(map: dic)

            #expect(parser.arrayIntType.count == 3)
            #expect(parser.arrayIntType[0] == 1)
            #expect(parser.arrayIntType[1] == 2)
            #expect(parser.arrayIntType[2] == 3)
        }

        @Test func testString() {
            let dic: [String: Any] = [
                "arrayStringType": ["a","b","c"]
            ]

            let parser = TestParserClass(map: dic)

            #expect(parser.arrayStringType.count == 3)
            #expect(parser.arrayStringType[0] == "a")
            #expect(parser.arrayStringType[1] == "b")
            #expect(parser.arrayStringType[2] == "c")
        }
    }

    struct InitTests {
        @Test func testInitAsyncAwait() async {
            let dic: [String: Any] = [
                "stringType": "Alice",
                "intType": 25,
                "boolType": true
            ]

            let obj = await TestParserClass.initAsync(map: dic)

            #expect(obj.stringType == "Alice")
            #expect(obj.intType == 25)
            #expect(obj.boolType == true)
        }

        @Test func testInitAsync() {
            let dic: [String: Any] = [
                "stringType": "Alice",
                "intType": 25,
                "boolType": true
            ]

            TestParserClass.initAsync(map: dic) { obj in
                #expect(obj.stringType == "Alice")
                #expect(obj.intType == 25)
                #expect(obj.boolType == true)
            }
        }
    }

    struct setSerializeTests {
        @Test func testSetSerialize() {
            let dic: [String: Any] = [
                "stringType": "Bob",
                "intType": 30,
                "boolType": false,
                "CGFloatType": 10.5
            ]

            let parser = TestParserClass(map: dic)

            #expect(parser.stringType == "Bob")
            #expect(parser.intType == 30)
            #expect(parser.boolType == false)
            #expect(parser.CGFloatType == 10.5)
        }

        @Test func testGetDataMap() {
            let dic: [String: Any] = [
                "username": "Bob",
                "user_age": 30,
                "active_status": false
            ]

            let parser = TestParserClass(map: dic)

            #expect(parser.stringType == "Bob")
            #expect(parser.intType == 30)
            #expect(parser.boolType == false)
        }

        @Test func testSubClass() {
            let dic: [String: Any] = [
                "classType": [ "stringType": "Alice",
                               "intType": 25,
                               "boolType": true
                             ]
            ]

            let obj = TestParserClass(map: dic)
            #expect(obj.classType?.stringType == "Alice")
            #expect(obj.classType?.intType == 25)
            #expect(obj.classType?.boolType == true)

        }
    }

    @Test func testChangeTypeValue() {
        let parser = PKHParser()

        #expect(parser.changeTypeValue(type: .string, value: 123) as? String == "123")
        #expect(parser.changeTypeValue(type: .int, value: "45") as? Int == 45)
        #expect(parser.changeTypeValue(type: .float, value: "3.14") as? Float == 3.14)
        #expect(parser.changeTypeValue(type: .bool, value: "true") as? Bool == true)
    }

    @Test func testDescription() {
        class TestParser: PKHParser {
            var stringType: String = ""
            var intType: Int = 0
            var boolType: Bool = false
        }

        let dic: [String: Any] = [
            "stringType": "Charlie",
            "intType": 40,
            "boolType": true
        ]

        let parser = TestParser(map: dic)
        let desc = parser.description
        print(desc)
//        #expect(desc == """
//                ✏️ ======== TestParser ======== ✏️
//                    stringType : Charlie
//                    intType : 40
//                    boolType : true
//                ✏️ ======== TestParser ======== ✏️
//                """)
    }
}
