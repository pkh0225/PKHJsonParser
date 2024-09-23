# PKHParser

👻 Easy Parsing JSON to Swift 

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## 목표
> 클라이언트 개발 시 json 파싱 과정에서 생기는 실수를 방지하고 불필요한 반복 작업을 줄여 파싱 과정을 자동화




<br>

## Test
```
let jsonString = """
{"widget": {
    "testDebug": "on",
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
"windowsDataList": [{
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
    }],
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
        let obj = Test(map: dic)
        print(obj)
        
        Test.parser(map: dic!) { (obj: Test) in
            print(obj)
        }

🎃 RESULT
======== Test ========
    windowsList: ---- Array(3) ----
    [0] ======== WindowsDataListItem ========
        name: main_window
        title: Sample Konfabulator Widget
        height: 500
        width: 500
        =======================================
    [1] ======== WindowsDataListItem ========
        name: main_window
        title: Sample Konfabulator Widget
        height: 500
        width: 500
        =======================================
    [2] ======== WindowsDataListItem ========
        name: main_window
        title: Sample Konfabulator Widget
        height: 500
        width: 500
        =======================================
    ---------------------------
    widgetData: ======== Widget ========
        stringArray: ---- Array(3) ----
        [0] a
        [1] b
        [2] c
        ---------------------------
        windowT: ======== WindowT ========
            name: main_window
            title: Sample Konfabulator Widget
            height: 500
            width: 500
            =======================================
        testImage: ======== TestImage ========
            alignment: center
            name: sun1
            src: Images/Sun.png
            hOffset: 250
            vOffset: 250
            =======================================
        testText: ======== TestText ========
            name: text1
            data: Click Here
            onMouseUp: sun1.opacity = (sun1.opacity / 100) * 90;
            alignment: center
            size: 36
            style: bold
            hOffset: 250
            vOffset: 100
            =======================================
        testDebug: on
        =======================================
    onMouseUp: sun1.opacity = (sun1.opacity / 100) * 90;
    name: text1
    alignment: center
    size: 36
    style: bold
    hOffset: 250
    vOffset: 100
    =======================================

```

## Core Functions


```

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
    
    override func afterParsed(_ dic: [String : Any]) {
        super.afterParsed(dic)
        
        // Parsering after
        
    }
}

@objcMembers open class PKHParser: NSObject {
    
    public override init() {
        super.init()
    }
    
    required public init(map dic: [String: Any]?, anyData: Any? = nil, serializeKey: String? = nil) {
        super.init()
        guard let dic = dic else { return }
        self.beforeParsed(dic:dic, anyData:anyData)
        if let key = serializeKey, let dataDic = dic[key] as? [String: Any] {
            self.setSerialize(map: dataDic, anyData: anyData)
            self.afterParsed(dataDic)
        }
        else {
            self.setSerialize(map: dic, anyData: anyData)
            self.afterParsed(dic)
        }
        
        
    }
    
    open func getDataMap() -> [ParserMap]? { return nil }
    open func beforeParsed(dic: [String: Any], anyData: Any?) {}
    open func afterParsed(_ dic: [String: Any]) {}
    open func setSerialize(map dic: [String: Any], anyData: Any?) {
        
        let maps = self.getDataMap()
        let ivarList = self.ivarInfoList()
        for ivarItem in ivarList {
            var changeKey = ivarItem.label
            var parserMap: ParserMap?
            if let maps = maps {
                for pm in maps {
                    if pm.ivar == ivarItem.label {
                        parserMap = pm
                        break;
                    }
                }
            }
            if parserMap != nil && parserMap!.jsonKey != "" {
                changeKey = parserMap!.jsonKey
            }
            
//            print(changeKey)
            guard let value = dic[changeKey] else { continue }
            guard value is NSNull == false else { continue }
            
            if ivarItem.classType == .array {
                guard let arrayValue = value as? [Any], arrayValue.count > 0 else { continue }
                guard let nsobjAbleType = ivarItem.subClassType as? PKHParser.Type else {
                    fatalError("self : [\(String(describing: self))] label : \(ivarItem.label)  \(String(describing: ivarItem.subClassType)) not NSObject" )
                    continue
                }
                var array: [Any] = []
                array.reserveCapacity(arrayValue.count)
                for arraySubDic in arrayValue {
                    if let dic = arraySubDic as? [String:Any] {
                        let addObj = nsobjAbleType.init(map: dic, anyData: anyData)
                        array.append(addObj)
                    }
                    
                }
                self.setValue(array, forKey: ivarItem.label)
            }
            else if ivarItem.classType == .dictionary {
                guard let nsobjAbleType = ivarItem.subClassType as? PKHParser.Type else {
                    fatalError("self : [\(String(describing: self))] label : \(ivarItem.label)  \(String(describing: ivarItem.subClassType)) not NSObject" )
                    continue
                }
                if let dic = value as? [String:Any], dic.keys.count > 0 {
                    let addObj = nsobjAbleType.init(map: dic, anyData: anyData)
                    self.setValue(addObj, forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .string {
                if value is String {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    self.setValue("\(value)", forKey: ivarItem.label)
                }
                
            }
            else if ivarItem.classType == .int {
                if value is Int {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toInt(), forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .float {
                if value is Float {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toFloat(), forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .bool {
                if value is Bool {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toBool(), forKey: ivarItem.label)
                }
            }
            else {
                self.setValue(value, forKey: ivarItem.label)
            }
            
            
        }
        
        
    }
    
    open override var description: String {
        return getDescription()
    }
    
    private enum descriptionType {
        case `default`
        case array
        case subInstance
    }
    
    private func getDescription(_ tapCount: UInt = 0, _ addType: descriptionType = .default) -> String {
        var tap = ""
        for _ in 0...tapCount { tap += "\t" }
        var result: [String] = []
        let ivarList = self.toDictionary()
        result.reserveCapacity(ivarList.count)
        switch addType {
        case .default:
            result.append("\n\(tap)✏️ ======== \(self.className) ✏️ ========")
        case .array:
            result.append("⬇️ --- \(self.className) ⬇️ ---")
        case .subInstance:
            result.append("➡️ --- \(self.className) ➡️ ---")
        }
        
        for (key, value) in ivarList {
            //            print("label: \(key), class: \(self.className) value: \(value)")
            
            
            if let arrayValue = value as? [Any] {
                result.append("\(key): ---- Array(\(arrayValue.count)) -------------------------------")
                for (idx,obj) in arrayValue.enumerated() {
                    if checkObjectClass(obj) {
                        result.append("[\(idx)] \(obj)")
                    }
                    else {
                        if let subArray = obj as? [Any] {
                            result.append("[\(idx)]---- SubArray(\(subArray.count)) ----")
                            for case let (subIdx,subItem as PKHParser) in subArray.enumerated() {
                                result.append("\t[\(subIdx)] \(subItem.getDescription(tapCount + 1, .array))")
                            }
                            result.append("---------------------------")
                        }
                        else if let objClass = obj as? PKHParser {
                            result.append("[\(idx)] \(objClass.getDescription(tapCount + 1, .array))")
                        }
                        else {
                            result.append("[\(idx)] \(String(describing: type(of: value))) ????????")
                            //                                assertionFailure("\(String(describing: value)) not NSObject" )
                        }
                    }
                }
                if arrayValue.count > 0 {
                    result.append("------------------------------------------------------")
                }
                
            }
            else if checkObjectClass(value as AnyObject) {
                result.append("\(key): \(value)")
            }
            else {
                if let objClass = value as? PKHParser {
                    result.append("\(key): \(objClass.getDescription(tapCount + 1, .subInstance))")
                }
                else {
                    result.append("\(key): \(String(describing: type(of: value))) ????????")
                    //                        assertionFailure("\(String(describing: value)) not NSObject" )
                }
            }
        }
        switch addType {
        case .default:
            result.append("✏️ ================== \(self.className) ===================== ✏️")
        case .array, .subInstance:
            result.append("----------- \(self.className)  -----------")
        }
        return result.joined(separator: "\n\(tap)")
    }
    
}
```
