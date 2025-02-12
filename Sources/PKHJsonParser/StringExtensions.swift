//
//  StringExtensions.swift
//  Test
//
//  Created by pkh on 2018. 8. 14..
//  Copyright © 2018년 pkh. All rights reserved.
//

import Foundation
#if os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS)
import UIKit
#endif

extension String {
    public var isValid: Bool {
        return !(self.isEmpty || self.trim().isEmpty || self == "(null)" || self == "null" || self == "nil")
    }

    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public func contains(_ find: String) -> Bool {
        return self.range(of: find) != nil
    }
    
    public func replace(_ of: String, _ with: String) -> String {
        return self.replacingOccurrences(of: of, with: with, options: .literal, range: nil)
    }
    
    public func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func toInt() -> Int {
        return NumberFormatter().number(from: self)?.intValue ?? 0
    }
    
    public func toDouble() -> Double {
        return NumberFormatter().number(from: self)?.doubleValue ?? 0
    }
    
    public func toFloat() -> Float {
        return NumberFormatter().number(from: self)?.floatValue ?? 0
    }
    
    public func toCGFloat() -> CGFloat {
        return CGFloat(NumberFormatter().number(from: self)?.doubleValue ?? 0)
    }
    
    public func toBool() -> Bool {
        let trimmedString = trimmed().lowercased()
        return (trimmedString == "true" || trimmedString == "y" || trimmedString == "yes")
    }

    public func toDictionary() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
}

