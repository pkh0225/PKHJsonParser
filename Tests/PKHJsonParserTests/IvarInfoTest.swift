import Testing
import Foundation
@testable import PKHJsonParser



struct IvarInfoTest {
    struct TestClassType {
        @Test() func testClass() async throws {
            class TestParserClass: NSObject {
                var a: TestParserSubClass?
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)

            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .class)
            #expect(iVarInfo.subClassType is TestParserSubClass.Type)
            #expect(iVarInfo.subValueType == .exceptType)
        }
    }
    struct TestArray {
        @Test func testArrayClass() async throws {
            class TestParserClass: NSObject {
                var a: [TestParserSubClass] = []
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .array)
            #expect(iVarInfo.subClassType is TestParserSubClass.Type)
            #expect(iVarInfo.subValueType == .exceptType)
        }

        @Test func testArrayString() async throws {
            class TestParserClass: NSObject {
                var a: [String] = []
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .array)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .string)
        }

        @Test func testArrayInt() async throws {
            class TestParserClass: NSObject {
                var a: [Int] = []
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .array)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .int)
        }

        @Test func testArrayCGFloat() async throws {
            class TestParserClass: NSObject {
                var a: [CGFloat] = []
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .array)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .cgfloat)
        }

        @Test func testArrayFloat() async throws {
            class TestParserClass: NSObject {
                var a: [Float] = []
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .array)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .float)
        }

        @Test func testArrayDouble() async throws {
            class TestParserClass: NSObject {
                var a: [Double] = []
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .array)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .double)
        }

        @Test func testArrayBool() async throws {
            class TestParserClass: NSObject {
                var a: [Bool] = []
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .array)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .bool)
        }
    }

    struct TestAny {
        @Test func testArrayAny() async throws {
            class TestParserClass: NSObject {
                var a: [Any] = []
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .any)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .exceptType)
        }

        @Test func testType() async throws {
            class TestParserClass: NSObject {
                var a: NSObject.Type = NSObject.self
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .any)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .exceptType)
        }

        @Test func testDictionaryAny() async throws {
            class TestParserClass: NSObject {
                var a: [String: Any] = [:]
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .any)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .exceptType)
        }

        @Test func testOptionalAny() async throws {
            class TestParserClass: NSObject {
                var a: Any?
            }

            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .any)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .exceptType)
        }

        @Test func testOptionalAnyObject() async throws {
            class TestParserClass: NSObject {
                var a: AnyObject?
            }
            let ivarInfos = getIvarInfoList(TestParserClass.self)
            let iVarInfo = try #require(ivarInfos.first)
            #expect(iVarInfo.label == "a")
            #expect(iVarInfo.classType == .any)
            #expect(iVarInfo.subClassType == nil)
            #expect(iVarInfo.subValueType == .exceptType)
        }
    }

    @Test func testIvarInfoClassType() async throws {
        #expect(IvarInfo.IvarInfoClassType(string: "Any") == .any)
        #expect(IvarInfo.IvarInfoClassType(string: "Array") == .array)
        #expect(IvarInfo.IvarInfoClassType(string: "class") == .class)
        #expect(IvarInfo.IvarInfoClassType(string: "String") == .string)
        #expect(IvarInfo.IvarInfoClassType(string: "Int") == .int)
        #expect(IvarInfo.IvarInfoClassType(string: "CGFloat") == .cgfloat)
        #expect(IvarInfo.IvarInfoClassType(string: "Float") == .float)
        #expect(IvarInfo.IvarInfoClassType(string: "Double") == .double)
        #expect(IvarInfo.IvarInfoClassType(string: "Bool") == .bool)
        #expect(IvarInfo.IvarInfoClassType(string: "exceptType") == .exceptType)
        #expect(IvarInfo.IvarInfoClassType(string: "abc") == .exceptType)
    }

    @Test func testBool() async throws {
        class TestParserClass: PKHParser {
            var x: Bool = true
        }
        let ivarInfos = getIvarInfoList(TestParserClass.self)
        let iVarInfo = try #require(ivarInfos.first)
        #expect(ivarInfos.count == 1)
        #expect(iVarInfo.label == "x")
        #expect(iVarInfo.classType == .bool)
        #expect(iVarInfo.subClassType == nil)
        #expect(iVarInfo.subValueType == .exceptType)
    }

    @Test func testDouble() async throws {
        class TestParserClass: PKHParser {
            var x: Double = 10.1
        }
        let ivarInfos = getIvarInfoList(TestParserClass.self)
        let iVarInfo = try #require(ivarInfos.first)
        #expect(ivarInfos.count == 1)
        #expect(iVarInfo.label == "x")
        #expect(iVarInfo.classType == .double)
        #expect(iVarInfo.subClassType == nil)
        #expect(iVarInfo.subValueType == .exceptType)
    }

    @Test func testCGFloat() async throws {
        class TestParserClass: PKHParser {
            var x: CGFloat = 10.1
        }
        let ivarInfos = getIvarInfoList(TestParserClass.self)
        let iVarInfo = try #require(ivarInfos.first)
        #expect(ivarInfos.count == 1)
        #expect(iVarInfo.label == "x")
        #expect(iVarInfo.classType == .cgfloat)
        #expect(iVarInfo.subClassType == nil)
        #expect(iVarInfo.subValueType == .exceptType)
    }

    @Test func testFloat() async throws {
        class TestParserClass: PKHParser {
            var x: Float = 10.1
        }
        let ivarInfos = getIvarInfoList(TestParserClass.self)
        let iVarInfo = try #require(ivarInfos.first)
        #expect(ivarInfos.count == 1)
        #expect(iVarInfo.label == "x")
        #expect(iVarInfo.classType == .float)
        #expect(iVarInfo.subClassType == nil)
        #expect(iVarInfo.subValueType == .exceptType)
    }

    @Test func testString() async throws {
        class TestParserClass: PKHParser {
            var x: String = "10"
        }
        let ivarInfos = getIvarInfoList(TestParserClass.self)
        let iVarInfo = try #require(ivarInfos.first)
        #expect(ivarInfos.count == 1)
        #expect(iVarInfo.label == "x")
        #expect(iVarInfo.classType == .string)
        #expect(iVarInfo.subClassType == nil)
        #expect(iVarInfo.subValueType == .exceptType)
    }

    @Test func testInt() async throws {
        class TestParserClass: PKHParser {
            var x: Int = 10
        }
        let ivarInfos = getIvarInfoList(TestParserClass.self)
        let iVarInfo = try #require(ivarInfos.first)
        #expect(ivarInfos.count == 1)
        #expect(iVarInfo.label == "x")
        #expect(iVarInfo.classType == .int)
        #expect(iVarInfo.subClassType == nil)
        #expect(iVarInfo.subValueType == .exceptType)
    }

    @Test func testCount() async throws {
        class TestParserClass: PKHParser {
            var x: Int = 10
            var y: Int = 100
        }
        let ivarInfos = getIvarInfoList(TestParserClass.self)

        #expect(ivarInfos.count == 2)
    }

    @Test func testSuperClass() async throws {
        let ivarInfos1 = getIvarInfoList(TestParserClass.self)
        #expect(ivarInfos1.count == 10)

        let ivarInfos2 = getIvarInfoList(TestSuperParser.self)
        let iVarInfo2 = try #require(ivarInfos2.first)
        #expect(ivarInfos2.count == 1)
        #expect(iVarInfo2.label == "superVar")
        #expect(iVarInfo2.classType == .string)
        #expect(iVarInfo2.subClassType == nil)
        #expect(iVarInfo2.subValueType == .exceptType)
    }

    @Test func testSwiftClassFromString() async throws {
        let testClass: AnyClass? = swiftClassFromString("TestParserClass")
        #expect(testClass is TestParserClass.Type)
    }

    @Test func testSwiftClassFromString2() async throws {
        let testClass: AnyClass? = swiftClassFromString("TestSuperParser")
        #expect(testClass is TestSuperParser.Type)
    }
}
