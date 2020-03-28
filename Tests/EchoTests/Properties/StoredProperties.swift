import XCTest
import EchoProperties

private protocol Protocol {}
extension Int: Protocol {}

private class Class {
  var int: Int = 0
  weak var cls: Class? = nil
}

private struct Struct<T: Equatable> {
  var existential: Protocol
  var generic: [T]
}

enum StoredPropertyTests {
  static func testStruct() throws {
    let storedProperties = MemoryLayout<Struct<[Int]>>.storedProperties
    XCTAssertEqual(storedProperties.count, 2)

    let existentialStoredProperty = storedProperties[0]
    XCTAssertEqual(existentialStoredProperty.name, "existential")
    XCTAssertTrue(existentialStoredProperty.type == Protocol.self)
    XCTAssertEqual(existentialStoredProperty.referenceStorage, .none)

    let genericStoredProperty = storedProperties[1]
    XCTAssertEqual(genericStoredProperty.name, "generic")
    XCTAssertTrue(genericStoredProperty.type == [[Int]].self)
    XCTAssertEqual(genericStoredProperty.referenceStorage, .none)
  }

  static func testClass() throws {
    let storedProperties = MemoryLayout<Class>.storedProperties
    XCTAssertEqual(storedProperties.count, 2)

    let intStoredProperty = storedProperties[0]
    XCTAssertEqual(intStoredProperty.name, "int")
    XCTAssertTrue(intStoredProperty.type == Int.self)
    XCTAssertEqual(intStoredProperty.referenceStorage, .none)

    let clsStoredProperty = storedProperties[1]
    XCTAssertEqual(clsStoredProperty.name, "cls")
    XCTAssertTrue(clsStoredProperty.type == Class?.self)
    XCTAssertEqual(clsStoredProperty.referenceStorage, .weak)
  }
}

extension EchoTests {
  func testStoredProperties() throws {
    try StoredPropertyTests.testStruct()
    try StoredPropertyTests.testClass()
  }
}
