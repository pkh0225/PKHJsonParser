//
//  ViewController.swift
//  PKHParserTest
//
//  Created by pkh on 2021/08/09.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var testButton: UIButton!

    let jsonString = """
    {
        "widget": {
            "testDebug": "on",
            "testDebug2": 99,
            "stringArray": ["a","b","c",1234],
            "intArray": [1,2,1234, "abd"],
            "cgfloatArray": [1,2,1234,"abd"],
            "floatArray": [1,2,123.4],
            "doublerray": [1,2,123.4],
            "boolArray": [0,1,2,1234,"abd"],
            "dicData": {"a": {"aa": "11",
                               "ab": "12"},
                        "b": {"bb": "22"}},
            "enumText": "bbb",
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
        "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;",
        "boolTest": true
    }
    """

    override func viewDidLoad() {
        super.viewDidLoad()
        let dic = jsonString.toDictionary()
        let obj = Test(map: dic!)
        print(obj)
    }


    @IBAction func onTest(_ sender: UIButton) {
        let dic = jsonString.toDictionary()
        Test.initAsync(map: dic!) { (obj: Test) in
            print(obj)
        }
    }
}

