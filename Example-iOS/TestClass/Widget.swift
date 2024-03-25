/*
    JsonToClass pkh
    Widget.swift

    Created by pkh on 2018. 08. 14..
*/

import Foundation
enum TestEmum: String {
    case aaa
    case bbb
}

class Widget : PKHParser {

    var testImage: TestImage?
    var testText: TestText?
    var stringArray = [String]()
    var windowT: WindowT?
    var testDebug: String = ""
    var testDebug2: Int = 0
    var intArray = [Int]()
    var cgfloatArray = [CGFloat]()
    var floatArray = [Float]()
    var doublerray = [Double]()
    var boolArray = [Bool]()
    var dicData = [String: Any]()
    var enumText = TestEmum.aaa
}

