import Testing
import Foundation
@testable import PKHJsonParser

// Sample Struct conforming to JSONSerializable
struct User: JSONSerializable {
    let id: CGFloat
    let name: String
    let age: Int
    let isActive: Bool
    let array1: [String] = ["a", "b", "c"]
    let array2: [Int] = [1, 2, 3]
}

struct JSONSerializableTest {
    @Test func jsonRepresentation() async throws {
        let user = User(
            id: 1,
            name: "Alice",
            age: 25,
            isActive: true
        )

        let json = user.JSONRepresentation

        #expect(json["id"] as? CGFloat == 1)
        #expect(json["name"] as? String == "Alice")
        #expect(json["age"] as? Int == 25)
        #expect(json["isActive"] as? Bool == true)
        #expect(json["array1"] as? [String] == ["a", "b", "c"])
        #expect(json["array2"] as? [Int] == [1, 2, 3])
    }

    @Test func toJSON() async throws {
        let user = User(id: 2, name: "Bob", age: 30, isActive: false)

        let jsonString = user.toJSON()

        #expect(jsonString?.contains("\"id\" : 2") == true)
        #expect(jsonString?.contains("\"name\" : \"Bob\"") == true)
        #expect(jsonString?.contains("\"age\" : 30") == true)
        #expect(jsonString?.contains("\"isActive\" : false") == true)
        #expect(jsonString?.contains("\"array1\" : [\n    \"a\",\n    \"b\",\n    \"c\"\n  ]") == true)
    }

    @Test func optionalJSONSerialization() async throws {
        let optionalUser: User? = User(id: 3, name: "Charlie", age: 28, isActive: true)

        let json = optionalUser.JSONRepresentation

        #expect(json["id"] as? Int == 3)
        #expect(json["name"] as? String == "Charlie")
        #expect(json["age"] as? Int == 28)
        #expect(json["isActive"] as? Bool == true)
        #expect(json["array1"] as? [String] == ["a", "b", "c"])
        #expect(json["array2"] as? [Int] == [1, 2, 3])
    }

    @Test func optionalNilJSONSerialization() async throws {
        let optionalNilUser: User? = nil

        let json = optionalNilUser.JSONRepresentation

        #expect(json.isEmpty == true)
    }
}
