//
//  PKHParserTestTests.swift
//  PKHParserTestTests
//
//  Created by pkh on 2021/08/09.
//

import XCTest
@testable import PKHParserTest

class PKHParserTestTests: XCTestCase {
    var  jsonString: String!
    var testObj: Test!

    override func setUpWithError() throws {
        jsonString = """
        {
            "widget": {
                "testDebug": "on",
                "testDebug2": 99,
                "stringArray": ["a","b","c"],
                "windowT": {
                    "title": "Sample Konfabulator Widget",
                    "name": "main_window",
                    "width": 500,
                    "height": 500
                },
                "testImage": {
                    "src": "Images/Sun.png",
                    "name": "sun1",
                    "hOffset": 250,
                    "vOffset": 250,
                    "alignment": "center"
                },
                "testText": {
                    "data": "Click Here",
                    "size": 36,
                    "style": "bold",
                    "name": "text1",
                    "hOffset": 250,
                    "vOffset": 100,
                    "alignment": "center",
                    "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
                }
            },
            "windowsDataList": [
                {
                    "title": "Sample Konfabulator Widget",
                    "name": "main_window",
                    "width": 500,
                    "height": 500
                },
                {
                    "title": "Sample Konfabulator Widget",
                    "name": "main_window",
                    "width": 500,
                    "height": 500
                },
                {
                    "title": "Sample Konfabulator Widget",
                    "name": "main_window",
                    "width": 500,
                    "height": 500
                }
            ],
            "size": 36,
            "style": "bold",
            "name": "text1",
            "hOffset": 250,
            "vOffset": 100,
            "alignment": "center",
            "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
        }
        """
        let dic = jsonString.toDictionary()
        testObj = Test(map: dic!)
//        print(obj)

//        Test.initAsync(map: dic!) { (obj: Test) in
//            print(obj)
//        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMainClass() throws {
        do {
            //given
            let expectedValue = "bold"
            //when
            let testingResult = testObj.style
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = "sun1.opacity = (sun1.opacity / 100) * 90;"
            //when
            let testingResult = testObj.onMouseUp
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = 36
            //when
            let testingResult = testObj.size
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = 250
            //when
            let testingResult = testObj.hOffset
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = 100
            //when
            let testingResult = testObj.vOffset
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = "center"
            //when
            let testingResult = testObj.alignment
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = "text1"
            //when
            let testingResult = testObj.name
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
    }

    func testSubClass() throws {
        do {
            //given
            let expectedValue = "on"
            //when
            let testingResult = testObj.widgetData?.testDebug ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = 99
            //when
            let testingResult = testObj.widgetData?.testDebug2 ?? 0
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
    }

    func testSubSub1Class() throws {
        do {
            //given
            let expectedValue = "center"
            //when
            let testingResult = testObj.widgetData?.testImage?.alignment ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = 250
            //when
            let testingResult = testObj.widgetData?.testImage?.hOffset ?? 0
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = 250
            //when
            let testingResult = testObj.widgetData?.testImage?.vOffset ?? 0
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = "sun1"
            //when
            let testingResult = testObj.widgetData?.testImage?.name ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = "Images/Sun.png"
            //when
            let testingResult = testObj.widgetData?.testImage?.src ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
    }

    func testSubSub2Class() throws {
        do {
            //given
            let expectedValue = "Sample Konfabulator Widget"
            //when
            let testingResult = testObj.widgetData?.windowT?.title ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = 500
            //when
            let testingResult = testObj.widgetData?.windowT?.width ?? 0
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
            do {
                //given
                let expectedValue = 500
                //when
                let testingResult = testObj.widgetData?.windowT?.height ?? 0
                //then
                XCTAssertEqual(expectedValue, testingResult)
            }
        do {
            //given
            let expectedValue = "main_window"
            //when
            let testingResult = testObj.widgetData?.windowT?.name ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
    }

    func testSubClassArray() throws {
        //given
        let expectedValue = 3
        //when
        let testingResult = testObj.windowsList.count
        //then
        XCTAssertEqual(expectedValue, testingResult)

        for obj in testObj.windowsList {
            do {
                //given
                let expectedValue = "Sample Konfabulator Widget"
                //when
                let testingResult = obj.title
                //then
                XCTAssertEqual(expectedValue, testingResult)
            }
            do {
                //given
                let expectedValue = "main_window"
                //when
                let testingResult = obj.name
                //then
                XCTAssertEqual(expectedValue, testingResult)
            }
            do {
                //given
                let expectedValue = 500
                //when
                let testingResult = obj.width
                //then
                XCTAssertEqual(expectedValue, testingResult)
            }
            do {
                //given
                let expectedValue = 500
                //when
                let testingResult = obj.height
                //then
                XCTAssertEqual(expectedValue, testingResult)
            }
        }
    }

    func testStringArray() throws {
        do {
            //given
            let expectedValue = 3
            //when
            let testingResult = testObj.widgetData?.stringArray.count ?? 0
            //then
            XCTAssertEqual(expectedValue, testingResult)

        }
        do {
            //given
            let expectedValue = "a"
            //when
            let testingResult = testObj.widgetData?.stringArray[0] ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = "b"
            //when
            let testingResult = testObj.widgetData?.stringArray[1] ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
        do {
            //given
            let expectedValue = "c"
            //when
            let testingResult = testObj.widgetData?.stringArray[2] ?? ""
            //then
            XCTAssertEqual(expectedValue, testingResult)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
//            let dic = jsonString.toDictionary()
//            testObj = Test(map: dic!)
        }
    }

}
