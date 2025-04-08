//
//  ViewController.swift
//  PKHParserTest
//
//  Created by pkh on 2021/08/09.
//

import UIKit
import PKHJsonParser

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
    [
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
    [
                {
                    "title": "Sample Konfabulator Widget111111111",
                    "name": "main_window111111111",
                    "width": 500111111,
                    "height": 5001111111
                },
                {
                    "title": "Sample Konfabulator Widget1111111",
                    "name": "main_window1111111",
                    "width": 5001111111,
                    "height": 5001111111
                },
                {
                    "title": "Sample Konfabulator Widget1111111",
                    "name": "main_window1111111",
                    "width": 5001111111,
                    "height": 5001111111
                }
    ]
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

    }


    @IBAction func onTest(_ sender: UIButton) {
        let dic = jsonString.toDictionary()
        let obj = Test(map: dic!)
        print(obj)
    }

    @IBAction func onAsync(_ sender: Any) {
        let dic = jsonString.toDictionary()
        Test.initAsync(map: dic!) {
            print($0)
        }
    }

    @IBAction func onAsyncAwait(_ sender: UIButton) {
        Task {
            let dic = jsonString.toDictionary()
            let obj = await Test.initAsync(map: dic!)
            print(obj)
        }
    }

    @IBAction func onToJson(_ sender: UIButton) {
        let dic = jsonString.toDictionary()
        Test.initAsync(map: dic!) {
            print($0.toJSON() ?? "")
        }
    }
    
}

