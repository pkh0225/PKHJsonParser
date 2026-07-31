# PKHJsonParser

JSON을 Swift 객체로 자동 매핑하는 경량 파서입니다. `PKHParser` 상속만으로 프로퍼티 이름·타입에 맞춰 파싱하고, Codable용 loose 타입 래퍼도 제공합니다.

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%2012%2B%20%7C%20macOS%2010.15%2B%20%7C%20tvOS%2012%2B-lightgrey.svg)](Package.swift)

## 특징

- **반사 기반 자동 매핑** — `PKHParser`를 상속하고 프로퍼티만 선언하면 JSON 키와 자동 연결
- **느슨한 타입 변환** — `"123"` → `Int`, `1` → `String`, `"y"` → `Bool` 등
- **중첩 객체 / 배열** — 서브클래스, `[T]`, `[[T]]`, primitive 배열 지원
- **키 매핑** — `getDataMap()`으로 JSON 키와 프로퍼티 이름이 다를 때 연결
- **부모 값 주입** — `addParentData()`로 자식 객체에 부모 JSON 필드 전달
- **비동기 파싱** — completion / `async-await`
- **역직렬화** — `toJSON()` / `JSONRepresentation`
- **Codable 래퍼** — `@LooseInt`, `@LooseString`, `@LooseBool`, `@LooseDouble`, `@LooseFloat`

## 설치

### Swift Package Manager

Xcode: **File → Add Package Dependencies…**

```
https://github.com/pkh0225/PKHJsonParser.git
```

또는 `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pkh0225/PKHJsonParser.git", from: "1.3.7")
]
```

## 빠른 시작

```swift
import PKHJsonParser

@objcMembers
class User: PKHParser {
    var name: String = ""
    var age: Int = 0
    var isActive: Bool = false
}

let json = """
{"name": "Alice", "age": "25", "isActive": "y"}
"""

guard let dic = json.toDictionary() else { return }
let user = User(map: dic)

print(user.name)     // "Alice"
print(user.age)      // 25
print(user.isActive) // true
print(user)          // description으로 구조 출력
```

## 사용법

### 1. 기본 파싱

프로퍼티 이름과 JSON 키가 같으면 별도 설정 없이 매핑됩니다.

지원 타입: `String`, `Int`, `Float`, `CGFloat`, `Double`, `Bool`, `PKHParser` 서브클래스, 위 타입의 배열.

```swift
@objcMembers
class WindowT: PKHParser {
    var title: String = ""
    var name: String = ""
    var width: Int = 0
    var height: Int = 0
}

@objcMembers
class Widget: PKHParser {
    var testDebug: String = ""
    var stringArray = [String]()
    var windowT: WindowT?
}

let dic = jsonString.toDictionary()
let widget = Widget(map: dic?["widget"] as? [String: Any] ?? [:])
```

> `@objcMembers`(또는 Objective-C 호환 프로퍼티)가 필요합니다. `NSObject` KVC로 값을 넣기 때문입니다.

### 2. JSON 키 ↔ 프로퍼티 이름 매핑

```swift
@objcMembers
class Test: PKHParser {
    var widgetData: Widget?
    var windowsList = [WindowsDataListItem]()

    override func getDataMap() -> [ParserMap]? {
        [
            ParserMap(ivar: "windowsList", jsonKey: "windowsDataList"),
            ParserMap(ivar: "widgetData", jsonKey: "widget")
        ]
    }
}
```

### 3. 파싱 전/후 훅

```swift
override func beforeParsed(dic: [String: Any], anyData: Any?) {
    // setSerialize 이전
}

override func afterParsed(_ dic: [String: Any], anyData: Any?) {
    // setSerialize 이후 — 가공·검증 등
}
```

`anyData`로 파싱 컨텍스트를 함께 넘길 수 있습니다.

```swift
let obj = User(map: dic, anyData: context)
```

특정 키 아래 dictionary만 파싱하려면 `serializeKey`를 사용합니다.

```swift
let obj = User(map: responseDic, serializeKey: "data")
```

### 4. 부모 JSON 값을 자식에 주입

자식 클래스에서 `addParentData()`를 오버라이드하면, 배열/중첩 객체 생성 시 부모 dictionary의 값을 자식에 넣습니다.

```swift
@objcMembers
class Item: PKHParser {
    var id: String = ""
    var parentId: String = ""

    open override class func addParentData() -> [ParserMap]? {
        [ParserMap(ivar: "parentId", jsonKey: "id")]
    }
}
```

### 5. 비동기 파싱

```swift
// completion (백그라운드 파싱 → 메인에서 콜백)
Test.initAsync(map: dic) { obj in
    print(obj)
}

// async/await
Task {
    let obj = await Test.initAsync(map: dic)
    print(obj)
}
```

### 6. 객체 → JSON

`PKHParser`는 `JSONSerializable`을 구현합니다.

```swift
let obj = Test(map: dic)
print(obj.toJSON() ?? "")
print(obj.JSONRepresentation)
```

### 7. Codable용 Loose 프로퍼티 래퍼

타입이 들쭉날쭉한 API를 `Codable`로 받을 때 사용합니다.

```swift
struct Product: Codable {
    @LooseInt var productId: Int
    @LooseString var productName: String
    @LooseDouble var price: Double
    @LooseBool var isOnSale: Bool
    @LooseFloat var discount: Float
}

// product_id가 "1001", is_on_sale이 "y"여도 디코딩 성공
let product = try JSONDecoder().decode(Product.self, from: data)
```

| 래퍼 | 허용 입력 예 |
|------|-------------|
| `@LooseBool` | `true` / `"y"`, `"yes"`, `"true"` / `1` |
| `@LooseString` | 문자열 / 숫자 / Bool → 문자열 |
| `@LooseInt` | Int / `"123"` / Double(절사) |
| `@LooseDouble` | Double / `"67.89"` / Int |
| `@LooseFloat` | Float / 문자열 / Int |

## String 헬퍼

```swift
"{\"a\":1}".toDictionary()  // [String: Any]?
"123".toInt()               // 123
"3.14".toFloat()            // 3.14
"3.14".toDouble()
"3.14".toCGFloat()
"y".toBool()                // true
"  hello  ".trim()
```

## 예제 앱

`Example-iOS`에 샘플 모델과 UI가 있습니다. 동기/비동기 파싱, `toJSON()` 동작을 확인할 수 있습니다.

```
Example-iOS/
├── PKHParserTest/     # 앱 타깃
└── TestClass/         # Sample 모델 (Test, Widget, …)
```

## 요구 사항

| 항목 | 버전 |
|------|------|
| Swift | 5.5+ |
| iOS | 12.0+ |
| macOS | 10.15+ |
| tvOS | 12.0+ |

## 라이선스

[MIT](LICENSE) © 박길호
