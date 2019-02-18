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

@inline(__always) public func checkObjectClass(_ obj: Any) -> Bool {
    if (obj is String) || (obj is NSNumber) || (obj is Dictionary<String, Any>) {
        return true
    }
    else {
        return false
    }
}

let ParserObjectConcurrentQueue = DispatchQueue(label: "ParserObjectConcurrentQueue", qos: .userInitiated, attributes: .concurrent)

@objcMembers open class PKHParser: NSObject {
    
    private var _descriptionTab: String = "\t"
    
    public override init() {
        super.init()
    }
    
    //    public class func parser(map dic : [String: Any], anyData: Any? = nil, serializeKey: String? = nil, completionHandler: @escaping (ParserObject) -> Void) {
    //        self.parser(map: dic, anyData: anyData, serializeKey: serializeKey, as: self, completionHandler: completionHandler)
    //    }
    
    public class func parser<T:PKHParser>(map dic : [String: Any]?, anyData: Any? = nil, serializeKey: String? = nil, completionHandler: @escaping (T) -> Void) {
        guard let dic = dic else { return }
        ParserObjectConcurrentQueue.async {
            let obj = T.init(map: dic, anyData: anyData, serializeKey: serializeKey)
            DispatchQueue.main.async(execute: {
                completionHandler(obj)
            })
        }
        
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
    
    open func getDataMap() -> [ParserMap]? { return nil }
    open func beforeParsed(dic: [String: Any], anyData: Any?) {}
    open func afterParsed(_ dic: [String: Any], anyData: Any?) {}
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
                    assertionFailure("self : [\(self.className))] label : \(ivarItem.label)  \(String(describing: ivarItem.subClassType)) not NSObject" )
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
                    assertionFailure("self : [\(self.className)] label : \(ivarItem.label)  \(String(describing: ivarItem.subClassType)) not NSObject" )
                    continue
                }
                if let dic = value as? [String:Any], dic.isEmpty == false {
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
            else if ivarItem.classType == .cgfloat {
                if value is Float {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toCGFloat(), forKey: ivarItem.label)
                }
            }
            else if ivarItem.classType == .double {
                if value is Float {
                    self.setValue(value, forKey: ivarItem.label)
                }
                else {
                    let text = "\(value)"
                    self.setValue(text.toDouble(), forKey: ivarItem.label)
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
        var result: [String] = []
        let ivarList = self.toDictionary()
        result.reserveCapacity(ivarList.count)
        result.append("\n\(self._descriptionTab)📝 ======== \(self.className) ========")
        for (key, value) in ivarList {
            //            print("label: \(key), class: \(self.className) value: \(value)")
            
            
            if let arrayValue = value as? [Any] {
                result.append("\(key): ---- Array(\(arrayValue.count)) ----")
                for (idx,obj) in arrayValue.enumerated() {
                    if checkObjectClass(obj) {
                        result.append("[\(idx)] \(obj)")
                    }
                    else {
                        if let subArray = obj as? [Any] {
                            result.append("[\(idx)]---- SubArray(\(subArray.count)) ----")
                            for case let (subIdx,subItem as PKHParser) in subArray.enumerated() {
                                subItem._descriptionTab = "\t\(self._descriptionTab)"
                                result.append("\t[\(subIdx)] \(subItem.description)")
                            }
                            result.append("---------------------------")
                        }
                        else if let objClass = obj as? PKHParser {
                            objClass._descriptionTab = "\t\(self._descriptionTab)"
                            result.append("[\(idx)] \(objClass.description)")
                        }
                        else {
                            result.append("[\(idx)] \(String(describing: type(of: value))) ????????")
                            //                                assertionFailure("\(String(describing: value)) not NSObject" )
                        }
                    }
                }
                if arrayValue.count > 0 {
                    result.append("---------------------------")
                }
                
            }
            else if checkObjectClass(value as AnyObject) {
                result.append("\(key): \(value)")
            }
            else {
                if let objClass = value as? PKHParser {
                    objClass._descriptionTab = "\t\(self._descriptionTab)"
                    result.append("\(key): \(objClass.description)")
                }
                else {
                    result.append("\(key): \(String(describing: type(of: value))) ????????")
                    //                        assertionFailure("\(String(describing: value)) not NSObject" )
                }
            }
        }
        
        result.append("📝 =======================================")
        return result.joined(separator: "\n\(self._descriptionTab)")
    }
    
}

