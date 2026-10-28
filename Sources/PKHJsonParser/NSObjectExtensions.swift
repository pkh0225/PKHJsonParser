//
//  NSObjectExtensions.swift
//  ssg
//
//  Created by pkh on 2018. 1. 26..
//  Copyright © 2018년 emart. All rights reserved.
//

import Foundation

class ObjectInfoMap {
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
    else if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
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
        case exceptType // 예외 항목

        public init(string: String) {
            let value = string.lowercased()
            self = .init(rawValue: value) ?? .exceptType
        }

        static func from(type: Any.Type) -> IvarInfoClassType? {
            if type == String.self { return .string }
            if type == Int.self { return .int }
            if type == Float.self { return .float }
            if type == CGFloat.self { return .cgfloat }
            if type == Double.self { return .double }
            if type == Bool.self { return .bool }
            if type == Any.self || type == AnyObject.self { return .any }
            return nil
        }
    }

    var label: String = ""
    var classType: IvarInfoClassType = .exceptType
    var subClassType: AnyClass?
    var subValueType: IvarInfoClassType = .exceptType
    /// Int?/Bool? 등 값 타입 Optional — KVC 불가, ivar 직접 설정 필요
    var isOptional: Bool = false

//    public init(label: String, classType: IvarInfoClassType, subClassType: AnyClass?, value: Any?) {
//        self.label = label
//        self.classType = classType
//        self.subClassType = subClassType // subClas가 custom class인 array, dictionary 일때만 사용.
//    }
}

private protocol OptionalProtocol {
    static var wrappedType: Any.Type { get }
}
extension Optional: OptionalProtocol {
    static var wrappedType: Any.Type { Wrapped.self }
}

private protocol ArrayProtocol {
    static var elementType: Any.Type { get }
}
extension Array: ArrayProtocol {
    static var elementType: Any.Type { Element.self }
}

@inline(__always) public func getDictionaryExcludSuper(mirrored_object: Mirror) -> [String: Any] {
    var dict: [String: Any] = [String: Any]()
    for (label, value) in mirrored_object.children {
        guard let label else { continue }
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
        guard let label else { continue }

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

@inline(__always) func setOptionalIvarValue<T>(_ object: AnyObject, key: String, value: T?) {
    let cls: AnyClass = object_getClass(object)!
    for name in [key, "_" + key] {
        guard let ivar = class_getInstanceVariable(cls, name) else { continue }
        let ptr = Unmanaged.passUnretained(object).toOpaque().advanced(by: ivar_getOffset(ivar))
        ptr.assumingMemoryBound(to: T?.self).pointee = value
        return
    }
}

@inline(__always) private func makeIvarInfo(label: String, valueType: Any.Type, value: Any) -> IvarInfo {
    if let optType = valueType as? OptionalProtocol.Type {
        let wrapped = optType.wrappedType
        if let basicType = IvarInfo.IvarInfoClassType.from(type: wrapped) {
            return IvarInfo(label: label, classType: basicType, isOptional: true)
        }
        if let cls = wrapped as? AnyClass {
            return IvarInfo(label: label, classType: .`class`, subClassType: cls, isOptional: true)
        }
        return IvarInfo(label: label, classType: .exceptType, isOptional: true)
    }

    if let arrayType = valueType as? ArrayProtocol.Type {
        let element = arrayType.elementType
        if let basicType = IvarInfo.IvarInfoClassType.from(type: element) {
            if basicType == .any {
                return IvarInfo(label: label, classType: .any)
            }
            return IvarInfo(label: label, classType: .array, subValueType: basicType)
        }
        if let cls = element as? AnyClass {
            return IvarInfo(label: label, classType: .array, subClassType: cls)
        }
        return IvarInfo(label: label, classType: .exceptType)
    }

    if let basicType = IvarInfo.IvarInfoClassType.from(type: valueType) {
        return IvarInfo(label: label, classType: basicType)
    }

    // Dictionary, metatype 등
    let className = String(describing: valueType)
    if className.contains(".Type") || className.contains("Dictionary<") {
        return IvarInfo(label: label, classType: .any)
    }

    if value is String {
        return IvarInfo(label: label, classType: .string)
    }
    if value is Int {
        return IvarInfo(label: label, classType: .int)
    }
    if value is Float {
        return IvarInfo(label: label, classType: .float)
    }
    if value is CGFloat {
        return IvarInfo(label: label, classType: .cgfloat)
    }
    if value is Double {
        return IvarInfo(label: label, classType: .double)
    }
    if value is Bool {
        return IvarInfo(label: label, classType: .bool)
    }
    if Mirror(reflecting: value).displayStyle == .class, let cls = valueType as? AnyClass {
        return IvarInfo(label: label, classType: .`class`, subClassType: cls)
    }
    if Mirror(reflecting: value).displayStyle == .class {
        return IvarInfo(label: label, classType: .`class`, subClassType: swiftClassFromString(className))
    }
    return IvarInfo(label: label, classType: .exceptType)
}

@inline(__always) func getIvarInfoList(_ classType: NSObject.Type) -> [IvarInfo] {
    let mirror = Mirror(reflecting: classType.init())
    var ivarDataList = [IvarInfo]()
    ivarDataList.reserveCapacity(mirror.children.count)

    for case let (label?, value) in mirror.children {
        let label = label.replace("$__lazy_storage_$_", "")
        ivarDataList.append(makeIvarInfo(label: label, valueType: type(of: value), value: value))
    }

    if let superClass = class_getSuperclass(classType),
        superClass != PKHParser.self {
        let superIvarDataList = getIvarInfoList(superClass as! NSObject.Type)
        if !superIvarDataList.isEmpty {
            ivarDataList += superIvarDataList
        }
    }
    return ivarDataList
}

extension NSObject {
    @inline(__always) public func toDictionary() -> [String: Any] {
        let mirrored_object = Mirror(reflecting: self)
        return getDictionary(mirrored_object: mirrored_object)
    }

    @inline(__always) public func toDictionaryExcludeSuperClass() -> [String: Any] {
        let mirrored_object = Mirror(reflecting: self)
        return getDictionaryExcludSuper(mirrored_object: mirrored_object)
    }

    @inline(__always) func ivarInfoList() -> [IvarInfo] {
//        print(String(describing: type(of:self)))
        if let info = cache.object(forKey: self.className as NSString) {
            return info.ivarInfoList
        }
        else {
            let infoList: [IvarInfo] = getIvarInfoList(type(of: self))
            let info = ObjectInfoMap(ivarInfoList: infoList)
            cache.setObject(info, forKey: self.className as NSString)
            return infoList
        }
//        return getIvarInfoList(type(of:self))
    }
}

extension NSObject {
    public var className: String { String(describing: type(of: self)) }
    public class var className: String { String(describing: self) }
}
