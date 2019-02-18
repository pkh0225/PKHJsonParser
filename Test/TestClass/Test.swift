/*
    JsonToClass pkh
    Test.swift

    Created by pkh on 2018. 08. 14..
*/

import Foundation

class Test : PKHParser { 

    var widgetData: Widget?
    var windowsList = [WindowsDataListItem]()
    var style: String = ""
    var onMouseUp: String = ""
    var size: Int = 0
    var hOffset: Int = 0
    var vOffset: Int = 0
    var alignment: String = ""
    var name: String = ""

    // json key ans ivar Different
    override func getDataMap() -> [ParserMap]? {
        return [ParserMap(ivar: "windowsList", jsonKey: "windowsDataList"),
                ParserMap(ivar: "widgetData", jsonKey: "widget")]
    }

    override func beforeParsed(dic: [String : Any], anyData: Any?) {
        super.beforeParsed(dic: dic, anyData: anyData)
        
        // Parsering before
        
    }
    
    override func afterParsed(_ dic: [String : Any], anyData: Any?) {
        super.afterParsed(dic, anyData: anyData)
        
        // Parsering after
        
    }
}

