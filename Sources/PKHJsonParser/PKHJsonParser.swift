//
//  GlobalNSObject.swift
//  ssg
//
//  Created by pkh on 2018. 2. 6..
//  Copyright © 2018년 emart. All rights reserved.
//

import Foundation

public struct ParserMap {
    var ivar: String
    var jsonKey: String
    
    public init(ivar: String, jsonKey: String) {
        self.ivar = ivar
        self.jsonKey = jsonKey
    }
}

/// Helps compiler accept valid code it can't validate.
struct UncheckedSendableWrapper<Value, Value2>: @unchecked Sendable {
    let value: Value
    let value2: Value2
}

let ParserObjectConcurrentQueue = DispatchQueue(label: "ParserObjectConcurrentQueue", qos: .userInitiated, attributes: .concurrent)

public protocol ParserAsyncInitProtocal {}
extension ParserAsyncInitProtocal where Self: PKHParser {
    public static func initAsync(map dic: [String: Any]?, anyData: Any? = nil, serializeKey: String? = nil, completionHandler: @escaping @Sendable (Self) -> Void) {
        guard let dic else { return }
        let work = UncheckedSendableWrapper(value: dic, value2: anyData)
        ParserObjectConcurrentQueue.async {
            let obj = Self.init(map: work.value, anyData: work.value2, serializeKey: serializeKey)
            DispatchQueue.main.async { completionHandler(obj) }
        }
    }

    public static func initAsync(map dic: [String: Any]?, anyData: Any? = nil, serializeKey: String? = nil) async -> Self {
        guard let dic = dic else { return Self.init(map: [:]) }

//        return await Task {
            return Self.init(map: dic, anyData: anyData, serializeKey: serializeKey)
//        }.value
    }
}


@objcMembers open class PKHParser: NSObject, JSONSerializable, ParserAsyncInitProtocal {
    public override init() {
        super.init()
    }
    
    required public init(map dic: [String: Any], anyData: Any? = nil, serializeKey: String? = nil) {
        super.init()
        self.beforeParsed(dic:dic, anyData:anyData)
        if let key = serializeKey, let dataDic = dic[key] as? [String: Any] {
            self.setSerialize(map: dataDic, anyData: anyData)
            self.afterParsed(dataDic, anyData: anyData)
        }
        else {
            self.setSerialize(map: dic, anyData: anyData)
            self.afterParsed(dic, anyData: anyData)
        }
    }

    open class func addParentData() -> [ParserMap]? { return nil }
    open func getDataMap() -> [ParserMap]? { return nil }
    open func beforeParsed(dic: [String: Any], anyData: Any?) {}
    open func afterParsed(_ dic: [String: Any], anyData: Any?) {}
    open func setSerialize(map pDic: [String: Any], anyData: Any?) {
        let maps: [ParserMap]? = self.getDataMap()
        let ivarList: [IvarInfo] = self.ivarInfoList()
        for ivarItem in ivarList {
            var parserMaps: [ParserMap] = [ParserMap]()
            parserMaps.append(ParserMap(ivar: ivarItem.label, jsonKey: ivarItem.label))

            if let maps: [ParserMap] = maps {
                for pm: ParserMap in maps {
                    if pm.ivar == ivarItem.label {
                        parserMaps.append(pm)
                    }
                }
            }

            var data: Any?
            for map: ParserMap in parserMaps {
                if let dicValue = pDic[map.jsonKey] {
                    data = dicValue
                    break
                }
            }

            guard let value = data else { continue }
            guard value is NSNull == false else { continue }

//            if self.className == "DI_TSpecialDeal" {
//                print("\(self.className)")
//            }

//            if ivarItem.label == "comm" {
//                print(ivarItem.label)
//            }

            if ivarItem.classType == .array {
                guard let arrayValue = value as? [Any], arrayValue.count > 0 else { continue }
                if let nsobjAbleType = ivarItem.subClassType as? PKHParser.Type {
                    var array: [Any] = []
                    array.reserveCapacity(arrayValue.count)
                    for arraySubDic in arrayValue {
                        if let dic = arraySubDic as? [String: Any], dic.isEmpty == false {
                            if let parentDatas = nsobjAbleType.addParentData(), parentDatas.count > 0 {
                                let addDic = addParentData(nsobjAbleType, parentDic: pDic, subDic: dic)
                                let addObj = nsobjAbleType.init(map: addDic, anyData: anyData)
                                array.append(addObj)
                            }
                            else {
                                let addObj = nsobjAbleType.init(map: dic, anyData: anyData)
                                array.append(addObj)
                            }
                        }
                        else if let subArray = arraySubDic as? [Any], subArray.count > 0 {
                            var addSubarray: [Any] = []
                            addSubarray.reserveCapacity(subArray.count)
                            for ssDic in subArray {
                                if let dic = ssDic as? [String: Any], dic.isEmpty == false {
                                    if let parentDatas = nsobjAbleType.addParentData(), parentDatas.count > 0 {
                                        let addDic = addParentData(nsobjAbleType, parentDic: pDic, subDic: dic)
                                        let addObj = nsobjAbleType.init(map: addDic, anyData: anyData)
                                        addSubarray.append(addObj)
                                    }
                                    else {
                                        let addObj = nsobjAbleType.init(map: dic, anyData: anyData)
                                        addSubarray.append(addObj)
                                    }
                                }
                            }
                            if addSubarray.count > 0 {
                                array.append(addSubarray)
                            }
                        }
                    }
                    self.setValue(array, forKey: ivarItem.label)
                }
                else {
                    var array: [Any] = []
                    array.reserveCapacity(arrayValue.count)
                    for arraySub in arrayValue {
                        if let data = changeTypeValue(type: ivarItem.subValueType, value: arraySub) {
                            array.append(data)
                        }
                    }
                    self.setValue(array, forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .dictionary {
                guard let nsobjAbleType = ivarItem.subClassType as? PKHParser.Type else {
                    // PKHParser상속 안받은 놈들은 건너뜀
//                    assertionFailure("self : [\(self.className)] label : \(ivarItem.label)  \(String(describing: ivarItem.subClassType)) not NSObject" )
                    continue
                }
                if let dic = value as? [String: Any], dic.isEmpty == false {
                    if let parentDatas = nsobjAbleType.addParentData(), parentDatas.count > 0 {
                        let addDic = addParentData(nsobjAbleType, parentDic: pDic, subDic: dic)
                        let addObj = nsobjAbleType.init(map: addDic, anyData: anyData)
                        self.setValue(addObj, forKey: ivarItem.label)
                    }
                    else {
                        let addObj = nsobjAbleType.init(map: dic, anyData: anyData)
                        self.setValue(addObj, forKey: ivarItem.label)
                    }
                }
            }
            else  if let data = changeTypeValue(type: ivarItem.classType, value: value) {
                self.setValue(data, forKey: ivarItem.label)
            }
            else if ivarItem.classType == .any {
                self.setValue(value, forKey: ivarItem.label)
            }
            else if ivarItem.classType == .exceptType {
                continue
            }
            else {
                print("""


                🧨🧨🧨   파싱 오류입니다.  🧨🧨🧨
                ClassName: \(self.className), label: \(ivarItem.label), ValueType: \(String(describing: type(of: value)))


                """)
//                self.setValue(value, forKey: ivarItem.label)
            }
        }
    }

    func changeTypeValue(type: IvarInfo.IvarInfoClassType, value: Any) -> Any? {
        if type == .string {
            return value is String ? value : "\(value)"
        }
        else if type == .int {
            return value is Int ? value : "\(value)".toInt()
        }
        else if type == .float {
            return value is Float ? value : "\(value)".toFloat()
        }
        else if type == .cgfloat {
            return value is Float ? value : "\(value)".toCGFloat()
        }
        else if type == .double {
            return value is Double ? value : "\(value)".toDouble()
        }
        else if type == .bool {
            return value is Bool ? value : "\(value)".toBool()
        }
        return nil
    }

    private func addParentData(_ type: PKHParser.Type, parentDic: [String: Any], subDic: [String: Any]) -> [String: Any] {
        guard let parentDatas = type.addParentData(), parentDatas.count > 0 else { return subDic }
        var resultDic = subDic
        parentDatas.forEach {
            if let v = parentDic[$0.jsonKey] {
                resultDic[$0.ivar] = v
            }
        }
        return resultDic
    }

    override open var description: String {
        var result: [String] = []
        result.append("✏️ ======== \(self.className) ======== ✏️")
        let str = getDescription(1, mirrored_object: Mirror(reflecting: self))
        if str.isValid {
            result.append("\t\(str)")
        }
        result.append("✏️ ======== \(self.className) ======== ✏️")
        return result.joined(separator: "\n")
    }

    private func getDescription(_ tapCount: UInt = 1, mirrored_object: Mirror) -> String {
        var tap: String = ""
        for _ in 1...tapCount { tap += "\t" }
        var result: [String] = []

        if let parent: Mirror = mirrored_object.superclassMirror {
            let str = getDescription(tapCount, mirrored_object: parent)
            if str.isValid {
                result.append( str )
            }
        }

        for (label, value) in mirrored_object.children {
            guard let label = label else { continue }
            if value is String || value is Int || value is Float || value is CGFloat || value is Double || value is Bool {
                result.append("\(label) : \(value)")
            }
            else if let objList = value as? [[PKHParser]] {
                var strList = [String]()
                if objList.count > 0 {
                    for (idx, obj) in objList.enumerated() {
                        strList.append("[\(idx)]")
                        for (idx, subObj) in obj.enumerated() {
                            strList.append("\t[\(idx)] \(subObj.getDescription(tapCount + 2, mirrored_object: Mirror(reflecting: subObj)))")
                        }
                        if idx == 0 {
                            result.append("\(label) : ⬇️ --- \(obj[safe: 0]?.className ?? "count = 0") ⬇️ ------")
                        }
                    }
                    result.append(contentsOf: strList)
                    result.append("------------------------------------------------------------")
                }
                else {
                    result.append("\(label) : ⬇️ --- count = 0 ⬇️ ------")
                }

            }
            else if let objList = value as? [PKHParser] {
                var strList = [String]()

                if objList.count > 0 {
                    for (idx, obj) in objList.enumerated() {
                        strList.append("[\(idx)] \(obj.getDescription(tapCount + 1, mirrored_object: Mirror(reflecting: obj)))")
                    }
                    result.append("\(label) : ⬇️ --- \(objList[safe: 0]?.className ?? "count = 0") ⬇️ ------")
                    result.append(contentsOf: strList)
                    result.append("------------------------------------------------------------")
                }
                else {
                    result.append("\(label) : ⬇️ --- count = 0 ⬇️ ------")
                }

            }
            else if let objList = value as? [String] {
                var strList = [String]()
                for (idx, obj) in objList.enumerated() {
                    strList.append("\t[\(idx)] \(obj)")
                }
                result.append("\(label) : ⬇️ --- String ⬇️ ------")
                result.append(contentsOf: strList)
                result.append("--------------------------------------------------------------")
            }

            else if let obj = value as? PKHParser {
                result.append("\(label) : ➡️ === \(obj.className) ======")
                result.append("\t\(obj.getDescription(tapCount + 1, mirrored_object: Mirror(reflecting: obj)))")
                result.append("-------- \(obj.className) -----------------------------------")
            }
            else {
                result.append("\(label) : \(value)")
            }
        }

        return result.joined(separator: "\n\(tap)")
    }
    
}

extension Array {
    public subscript(safe index: Int?) -> Element? {
        guard let index = index else { return nil }
        if indices.contains(index) {
            return self[index]
        }
        else {
            return nil
        }
    }
}
