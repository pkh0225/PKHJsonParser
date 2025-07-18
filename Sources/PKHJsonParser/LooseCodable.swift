//
//  LooseCodable.swift
//  PKHJsonParser
//
//  Created by 박길호 on 7/18/25.
//

import Foundation
/*
 import Foundation

 struct Product: Codable {
     @LooseInt var productId: Int
     @LooseString var productName: String
     @LooseDouble var price: Double
     @LooseBool var isOnSale: Bool
     @LooseInt var stock: Int

     enum CodingKeys: String, CodingKey {
         case productId = "product_id"
         case productName = "product_name"
         case price
         case isOnSale = "is_on_sale"
         case stock
     }
 }

 // --- 파싱 테스트 ---
 let jsonString = """
 {
     "product_id": "1001",
     "product_name": 123456,
     "price": "25000.50",
     "is_on_sale": "y",
     "stock": 99
 }
 """
 let jsonData = jsonString.data(using: .utf8)!

 do {
     let product = try JSONDecoder().decode(Product.self, from: jsonData)

     print("--- 파싱 성공 ---")
     print("ID: \(product.productId), 타입: \(type(of: product.productId))")
     print("이름: \(product.productName), 타입: \(type(of: product.productName))")
     print("가격: \(product.price), 타입: \(type(of: product.price))")
     print("세일: \(product.isOnSale), 타입: \(type(of: product.isOnSale))")
     print("재고: \(product.stock), 타입: \(type(of: product.stock))")

 } catch {
     print("파싱 실패: \(error)")
 }

 */
@propertyWrapper
public struct LooseBool: Codable, Equatable {
    public let wrappedValue: Bool

    public init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let boolValue = try? container.decode(Bool.self) {
            self.wrappedValue = boolValue
            return
        }

        if let stringValue = try? container.decode(String.self) {
            let lowercased = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            self.wrappedValue = (lowercased == "true" || lowercased == "y" || lowercased == "yes")
            return
        }

        if let intValue = try? container.decode(Int.self) {
            self.wrappedValue = (intValue != 0)
            return
        }

        throw DecodingError.typeMismatch(Bool.self, .init(codingPath: decoder.codingPath, debugDescription: "Could not decode Bool"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

@propertyWrapper
public struct LooseString: Codable, Equatable {
    public let wrappedValue: String

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            self.wrappedValue = stringValue
            return
        }

        if let intValue = try? container.decode(Int.self) {
            self.wrappedValue = "\(intValue)"
            return
        }

        if let doubleValue = try? container.decode(Double.self) {
            self.wrappedValue = "\(doubleValue)"
            return
        }

        if let boolValue = try? container.decode(Bool.self) {
            self.wrappedValue = "\(boolValue)"
            return
        }

        throw DecodingError.typeMismatch(String.self, .init(codingPath: decoder.codingPath, debugDescription: "Could not decode String"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

@propertyWrapper
public struct LooseInt: Codable, Equatable {
    public let wrappedValue: Int

    public init(wrappedValue: Int) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            self.wrappedValue = intValue
            return
        }

        if let stringValue = try? container.decode(String.self) {
            self.wrappedValue = Int(stringValue) ?? 0
            return
        }

        if let doubleValue = try? container.decode(Double.self) {
            self.wrappedValue = Int(doubleValue)
            return
        }

        throw DecodingError.typeMismatch(Int.self, .init(codingPath: decoder.codingPath, debugDescription: "Could not decode Int"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

@propertyWrapper
public struct LooseDouble: Codable, Equatable {
    public let wrappedValue: Double

    public init(wrappedValue: Double) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let doubleValue = try? container.decode(Double.self) {
            self.wrappedValue = doubleValue
            return
        }

        if let stringValue = try? container.decode(String.self) {
            self.wrappedValue = Double(stringValue) ?? 0.0
            return
        }

        if let intValue = try? container.decode(Int.self) {
            self.wrappedValue = Double(intValue)
            return
        }

        throw DecodingError.typeMismatch(Double.self, .init(codingPath: decoder.codingPath, debugDescription: "Could not decode Double"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// Float 용
@propertyWrapper
public struct LooseFloat: Codable, Equatable {
    public let wrappedValue: Float

    public init(wrappedValue: Float) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let doubleValue = try? container.decode(Float.self) {
            self.wrappedValue = doubleValue
            return
        }

        if let stringValue = try? container.decode(String.self) {
            self.wrappedValue = Float(stringValue) ?? 0.0
            return
        }

        if let intValue = try? container.decode(Int.self) {
            self.wrappedValue = Float(intValue)
            return
        }

        throw DecodingError.typeMismatch(Float.self, .init(codingPath: decoder.codingPath, debugDescription: "Could not decode Float"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
