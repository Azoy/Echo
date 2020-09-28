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

/// Asserts that the given named key path collections are equal.
func assertNamedKeyPathsEqual<Root>(
  _ actual: [(name: String, keyPath: PartialKeyPath<Root>)],
  _ expected: [(name: String, keyPath: PartialKeyPath<Root>)],
  file: StaticString = #filePath,
  line: UInt = #line
) {
  for (actual, expected) in zip(actual, expected) {
    XCTAssertEqual(actual.name, expected.name, file: file, line: line)
    XCTAssertEqual(actual.keyPath, expected.keyPath, file: file, line: line)
  }
}

enum StoredPropertyKeyPaths {
  static func testStruct() throws {
    let allKeyPaths = Reflection.allStoredPropertyKeyPaths(
      for: Struct<Int>.self)
    XCTAssertEqual(
      allKeyPaths,
      [\Struct<Int>.existential, \Struct<Int>.generic])

    let allNamedKeyPaths = Reflection.allNamedStoredPropertyKeyPaths(
      for: Struct<Int>.self)
    assertNamedKeyPathsEqual(
      allNamedKeyPaths,
      [
        ("existential", \Struct<Int>.existential),
        ("generic", \Struct<Int>.generic),
      ])
  }

  static func testClass() throws {
    // FIXME: Class property iteration fails.
    /*
    let allKeyPaths = Reflection.allStoredPropertyKeyPaths(for: Class.self)
    XCTAssertEqual(allKeyPaths, [\Class.int, \Class.cls])

    let allNamedKeyPaths = Reflection.allNamedStoredPropertyKeyPaths(
      for: Class.self)
    assertNamedKeyPathsEqual(
      allNamedKeyPaths, [("int", \Class.int), ("cls", \Class.cls)])
    */
  }
}

enum CustomKeyPaths {
  static func testStruct() throws {
    let s = Struct<Int>(existential: 1, generic: [2, 3])
    let allKeyPaths = Reflection.allKeyPaths(for: s)
    XCTAssertEqual(
      allKeyPaths,
      [\Struct<Int>.existential, \Struct<Int>.generic])

    let allNamedKeyPaths = Reflection.allNamedKeyPaths(for: s)
    assertNamedKeyPathsEqual(
      allNamedKeyPaths,
      [
        ("existential", \Struct<Int>.existential),
        ("generic", \Struct<Int>.generic),
      ])
  }

  static func testClass() throws {
    // FIXME: Class property iteration fails.
    /*
    let c = Class()
    let allKeyPaths = Reflection.allKeyPaths(for: c)
    XCTAssertEqual(allKeyPaths, [\Class.int, \Class.cls])

    let allNamedKeyPaths = Reflection.allNamedKeyPaths(for: c)
    assertNamedKeyPathsEqual(
      allNamedKeyPaths, [("int", \Class.int), ("cls", \Class.cls)])
    */
  }

  static func testArray() throws {
    let array = [0, 1, 2, 3]
    let allKeyPaths = Reflection.allKeyPaths(for: array)
    XCTAssertEqual(
      allKeyPaths,
      [\[Int][0], \[Int][1], \[Int][2], \[Int][3]])
    let allNamedKeyPaths = Reflection.allNamedKeyPaths(for: array)
    assertNamedKeyPathsEqual(
      allNamedKeyPaths,
      [
        ("0", \[Int][0]),
        ("1", \[Int][1]),
        ("2", \[Int][2]),
        ("3", \[Int][3]),
      ])
  }
}

extension EchoTests {
  func testStoredPropertyKeyPaths() throws {
    try StoredPropertyKeyPaths.testStruct()
    try StoredPropertyKeyPaths.testClass()
  }

  func testCustomKeyPaths() throws {
    try CustomKeyPaths.testStruct()
    try CustomKeyPaths.testClass()
    try CustomKeyPaths.testArray()
  }
}
