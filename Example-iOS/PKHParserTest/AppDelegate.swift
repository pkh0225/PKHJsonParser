//
//  AppDelegate.swift
//  PKHParserTest
//
//  Created by pkh on 2021/08/09.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let jsonString = """
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
            "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;",
            "boolTest": true
        }
        """
        let dic = jsonString.toDictionary()
        let obj = Test(map: dic!)
        print(obj)

        Test.initAsync(map: dic!) { (obj: Test) in
            print(obj)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

