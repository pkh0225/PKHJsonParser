//
//  NSObjectExtensions.swift
//  ssg
//
//  Created by pkh on 2018. 1. 26..
//  Copyright © 2018년 emart. All rights reserved.
//

import Foundation
import UIKit

public class ObjectInfoMap {
    public var ivarInfoList: [IvarInfo]
    
    public init(ivarInfoList: [IvarInfo]) {
        self.ivarInfoList = ivarInfoList
    }
}


public var Object_Info_Cache = NSCache<NSString, ObjectInfoMap>()

@inline(__always) public func swiftClassFromString(_ className: String, bundleName: String = "") -> AnyClass? {
    
    // get the project name
    if  let appName = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as? String {
        // generate the full name of your class (take a look into your "YourProject-swift.h" file)
        let classStringName = "\(appName).\(className)"
        guard let aClass = NSClassFromString(classStringName) else {
            let classStringName = "\(bundleName).\(className)"
            guard let aClass = NSClassFromString(classStringName) else {
                //                print(">>>>>>>>>>>>> [ \(className) ] : swiftClassFromString Create Fail <<<<<<<<<<<<<<")
                return nil
                
            }
            return aClass
        }
        return aClass
    }
    //    print(">>>>>>>>>>>>> [ \(className) ] : swiftClassFromString Create Fail <<<<<<<<<<<<<<")
    return nil
}

public struct  IvarInfo {
    
    public enum IvarInfoClassType {
        case any
        case array
        case dictionary
        case int
        case string
        case float
        case cgfloat
        case double
        case bool
        case exceptType //예외 항목
    }
    
    public var label: String = ""
    public var classType: IvarInfoClassType = .any
    public var subClassType: AnyClass?
    
    public init(label: String, classType: IvarInfoClassType, subClassType: AnyClass?, value: Any?) {
        self.label = label
        self.classType = classType
        self.subClassType = subClassType // subClas가 custom class인 array, dictionary 일때만 사용.
    }
}


@inline(__always) public func getDictionaryExcludSuper(mirrored_object: Mirror) -> [String: Any] {
    var dict: [String: Any] = [String: Any]()
    for (label, value) in mirrored_object.children {
        guard let label = label else { continue }
        if let objList = value as? [NSObject] {
            var dicList: [[String: Any]] = []
            for obj in objList {
                let dic = obj.toDictionary()
                dicList.append(dic)
            }
            dict[label] = dicList
        }
        else {
            dict[label] = value as AnyObject
        }

    }

    return dict
}

@inline(__always) public func getDictionary(mirrored_object: Mirror) -> [String: Any] {
    var dict: [String: Any] = [String: Any]()
    for (label, value) in mirrored_object.children {
        guard let label = label else { continue }
        guard label != "_debugAnyData" else { continue }
        guard label != "_debugJsonDic" else { continue }

        if value is String || value is Int || value is Float || value is CGFloat || value is Double || value is Bool {
            dict[label] = value as AnyObject
        }
        else if let objList = value as? [NSObject] {
            var dicList: [[String: Any]] = []
            for obj in objList {
                let dic = obj.toDictionary()
                dicList.append(dic)
            }
            dict[label] = dicList
        }
        else if let obj = value as? NSObject {
            let dic = obj.toDictionary()
            dict[label] = dic
        }
        else {
            dict[label] = value as AnyObject
        }
    }
    if let parent: Mirror = mirrored_object.superclassMirror {
        let dict2: [String: Any] = getDictionary(mirrored_object: parent)
        for (key, value) in dict2 {
            dict.updateValue(value, forKey: key)
        }
    }

    return dict
}




@inline(__always) public func getIvarInfoList(_ classType: NSObject.Type) -> [IvarInfo] {
    
    
    let mirror = Mirror(reflecting: classType.init())
    var ivarDataList = [IvarInfo]()
    ivarDataList.reserveCapacity(mirror.children.count)
    
    for case let (label?, value) in mirror.children {
        //        print("label: \(label), class: \(classType.className) value: \(value)")
        
        var className = String(describing: type(of: value))
        
        if className.contains("Array<String>") || className.contains("Array<Any>") || className.contains(".Type") || className.contains("Dictionary<") || className.contains("Optional<Any>") || className.contains("Optional<AnyObject>") {
            ivarDataList.append( IvarInfo(label: label, classType: .any, subClassType: nil, value: nil) )
        }
        else if className.contains("Array<") {
            className = className.replace(">", "")
            className = className.replace("Array<", "")
            ivarDataList.append( IvarInfo(label: label, classType: .array, subClassType: swiftClassFromString(className) , value: nil) )
        }
        else if className.contains("Optional<") || className.contains("ImplicitlyUnwrappedOptional<") {
            className = className.replace(">", "")
            className = className.replace("ImplicitlyUnwrappedOptional<", "")
            className = className.replace("Optional<", "")
            ivarDataList.append( IvarInfo(label: label, classType: .dictionary, subClassType: swiftClassFromString(className), value: nil) )
        }
        else {
            if value is String {
                ivarDataList.append( IvarInfo(label: label, classType: .string, subClassType: nil, value: nil) )
            }
            else if value is Int {
                ivarDataList.append( IvarInfo(label: label, classType: .int, subClassType: nil, value: nil) )
            }
            else if value is Float {
                ivarDataList.append( IvarInfo(label: label, classType: .float, subClassType: nil, value: nil) )
            }
            else if value is CGFloat {
                ivarDataList.append( IvarInfo(label: label, classType: .cgfloat, subClassType: nil, value: nil) )
            }
            else if value is Double {
                ivarDataList.append( IvarInfo(label: label, classType: .double, subClassType: nil, value: nil) )
            }
            else if value is Bool {
                ivarDataList.append( IvarInfo(label: label, classType: .bool, subClassType: nil, value: nil) )
            }
            else {
                if (Mirror(reflecting: value).displayStyle == .class) {
                    ivarDataList.append( IvarInfo(label: label, classType: .dictionary, subClassType: swiftClassFromString(className), value: nil) )
                }
                else  if (Mirror(reflecting: value).displayStyle == .`enum`){
                    ivarDataList.append( IvarInfo(label: label, classType: .exceptType, subClassType: nil, value: nil) )
                }
                else  if (Mirror(reflecting: value).displayStyle == .struct){
                     ivarDataList.append( IvarInfo(label: label, classType: .exceptType, subClassType: nil, value: nil) )
                }
                else {
                    ivarDataList.append( IvarInfo(label: label, classType: .any, subClassType: nil, value: nil) )
                }
            }
        }
    }
    
    if let superClass = class_getSuperclass(classType),
        superClass != PKHParser.self {
        let superIvarDataList = getIvarInfoList(superClass as! NSObject.Type)
        if superIvarDataList.count > 0 {
            ivarDataList += superIvarDataList
        }
    }
    
    
    
    return ivarDataList
}

extension NSObject {
    @inline(__always) public func toDictionary() -> [String: Any] {
        let mirrored_object: Mirror = Mirror(reflecting: self)
        return getDictionary(mirrored_object: mirrored_object)
    }

    @inline(__always) public func toDictionaryExcludeSuperClass() -> [String: Any] {
        let mirrored_object: Mirror = Mirror(reflecting: self)
        return getDictionaryExcludSuper(mirrored_object: mirrored_object)
    }

    @inline(__always) public func ivarInfoList() -> [IvarInfo] {
//        print(String(describing: type(of:self)))
        Object_Info_Cache.countLimit = 100
        if let info: ObjectInfoMap = Object_Info_Cache.object(forKey: self.className as NSString) {
            return info.ivarInfoList
        }
        else {
            let infoList: [IvarInfo] = getIvarInfoList(type(of: self))
            let info: ObjectInfoMap = ObjectInfoMap(ivarInfoList: infoList )
            Object_Info_Cache.setObject(info, forKey: self.className as NSString)
            return infoList
        }
//        return getIvarInfoList(type(of:self))
    }
}

extension NSObject {
    private struct AssociatedKeys {
        static var className: UInt8 = 0
        static var iVarName: UInt8 = 0
        static var iVarValue: UInt8 = 0
    }
    
    public var toInt: Int {
        return unsafeBitCast(self, to: Int.self)
    }
    
    public var tag_name: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.iVarName) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.iVarName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var tag_value: Any? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.iVarValue)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.iVarValue, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var className: String {
        if let name = objc_getAssociatedObject(self, &AssociatedKeys.className) as? String {
            return name
        }
        else {
            let name = String(describing: type(of:self))
            objc_setAssociatedObject(self, &AssociatedKeys.className, name, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return name
        }
        
        
    }
    
    public class var className: String {
        if let name = objc_getAssociatedObject(self, &AssociatedKeys.className) as? String {
            return name
        }
        else {
            let name = String(describing: self)
            objc_setAssociatedObject(self, &AssociatedKeys.className, name, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return name
        }
    }
}

