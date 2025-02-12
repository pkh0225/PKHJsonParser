import Testing
import Foundation
@testable import PKHJsonParser

class TestParserClass: TestSuperParser {
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


class TestSuperParser: PKHParser {
    var superVar: String = "1234"
}
