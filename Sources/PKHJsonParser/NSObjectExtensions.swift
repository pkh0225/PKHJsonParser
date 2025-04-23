//
//  NSObjectExtensions.swift
//  ssg
//
//  Created by pkh on 2018. 1. 26..
//  Copyright © 2018년 emart. All rights reserved.
//

import Foundation

actor ObjectInfoMap {
    let ivarInfoList: [IvarInfo]

    init(ivarInfoList: [IvarInfo]) {
        self.ivarInfoList = ivarInfoList
    }
}

private let cache = NSCache<NSString, ObjectInfoMap>()

@inline(__always) public func swiftClassFromString(_ className: String, bundleName: String = "") -> AnyClass? {
    func subFunc(className: String, bundleName: String) -> AnyClass? {
        guard !className.isEmpty, !bundleName.isEmpty else { return nil }
        return NSClassFromString("\(bundleName).\(className)")
    }

    if !bundleName.isEmpty, let classTyp = subFunc(className: className, bundleName: bundleName) {
        return classTyp
    }
    else if let bundleName = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as? String,
       let classTyp = subFunc(className: className, bundleName: bundleName) {
        return classTyp
    }
    else if let bundleName = Bundle.allBundles.first(where: { $0.bundlePath.contains(".xctest") })?.bundleIdentifier?.split(separator: ".").last,
            let classTyp = subFunc(className: className, bundleName: String(bundleName)) {
        return classTyp
    }
    return subFunc(className: className, bundleName: bundleName)
}

struct  IvarInfo {
    enum IvarInfoClassType: String {
        case any
        case array
        case `class`
        case int
        case string
        case float
        case cgfloat
        case double
        case bool
        case exceptType //예외 항목

        public init(string: String) {
            let value = string.lowercased()
            self = .init(rawValue: value) ?? .exceptType
        }
    }
    
    var label: String = ""
    var classType: IvarInfoClassType = .exceptType
    var subClassType: AnyClass? = nil
    var subValueType: IvarInfoClassType = .exceptType

//    public init(label: String, classType: IvarInfoClassType, subClassType: AnyClass?, value: Any?) {
//        self.label = label
//        self.classType = classType
//        self.subClassType = subClassType // subClas가 custom class인 array, dictionary 일때만 사용.
//    }
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




@inline(__always) func getIvarInfoList(_ classType: NSObject.Type) -> [IvarInfo] {
    let mirror = Mirror(reflecting: classType.init())
    var ivarDataList = [IvarInfo]()
    ivarDataList.reserveCapacity(mirror.children.count)
    
    for case let (label?, value) in mirror.children {
//        if label.contains("dicData") {
//            print("label: \(label), class: \(classType.className) value: \(String(describing: type(of: value)))")
//        }

        let label = label.replace("$__lazy_storage_$_", "")
        var className = String(describing: type(of: value))
        
        if className.contains("Array<Any>") || className.contains(".Type") || className.contains("Dictionary<") || className.contains("Optional<Any>") || className.contains("Optional<AnyObject>") {
            ivarDataList.append( IvarInfo(label: label, classType: .any))
        }
        else if className.contains("Array<") {
            var elementName = className.replace(">", "")
            elementName = elementName.replace("Array<", "")
            if elementName == "String" || elementName == "Int" || elementName == "CGFloat" || elementName == "Float" || elementName == "Double" || elementName == "Bool" {
                ivarDataList.append( IvarInfo(label: label, classType: .array, subValueType: IvarInfo.IvarInfoClassType(string: elementName)) )
            }
            else {
                ivarDataList.append( IvarInfo(label: label, classType: .array, subClassType: swiftClassFromString(elementName)) )
            }
        }
        else if className.contains("Optional<") || className.contains("ImplicitlyUnwrappedOptional<") {
            className = className.replace(">", "")
            className = className.replace("ImplicitlyUnwrappedOptional<", "")
            className = className.replace("Optional<", "")
            ivarDataList.append( IvarInfo(label: label, classType: .class, subClassType: swiftClassFromString(className)) )
        }
        else {
            if value is String {
                ivarDataList.append( IvarInfo(label: label, classType: .string) )
            }
            else if value is Int {
                ivarDataList.append( IvarInfo(label: label, classType: .int) )
            }
            else if value is Float {
                ivarDataList.append( IvarInfo(label: label, classType: .float) )
            }
            else if value is CGFloat {
                ivarDataList.append( IvarInfo(label: label, classType: .cgfloat) )
            }
            else if value is Double {
                ivarDataList.append( IvarInfo(label: label, classType: .double) )
            }
            else if value is Bool {
                ivarDataList.append( IvarInfo(label: label, classType: .bool) )
            }
            else {
                if (Mirror(reflecting: value).displayStyle == .class) {
                    ivarDataList.append( IvarInfo(label: label, classType: .class, subClassType: swiftClassFromString(className)) )
                }
                else {
                     ivarDataList.append( IvarInfo(label: label, classType: .exceptType) )
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

    @inline(__always) func ivarInfoList() -> [IvarInfo] {
//        print(String(describing: type(of:self)))
        if let info = cache.object(forKey: self.className as NSString) {
            return info.ivarInfoList
        }
        else {
            let infoList: [IvarInfo] = getIvarInfoList(type(of: self))
            let info: ObjectInfoMap = ObjectInfoMap(ivarInfoList: infoList )
            cache.setObject(info, forKey: self.className as NSString)
            return infoList
        }
//        return getIvarInfoList(type(of:self))
    }
}

extension NSObject {
    public var className: String { String(describing: type(of:self)) }
    public class var className: String { String(describing: self) }
}

