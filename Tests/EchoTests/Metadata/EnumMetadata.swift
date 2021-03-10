import XCTest
import Echo

enum Colors2<T> {
  case red
  case blue(T)
  indirect case green(Colors2<T>)
}

enum EnumMetadataTests {
  static func testEnum() throws {
    let maybeMetadata = reflectEnum(Colors.self)
    XCTAssertNotNil(maybeMetadata)
    
    let metadata = maybeMetadata!
    
    XCTAssert(metadata.kind == .enum || metadata.kind == .optional)
    XCTAssertEqual(metadata.fieldOffsets, [])
    XCTAssert(typeArraysEquals(metadata.genericTypes, []))
    
    // VWT
    
    XCTAssertEqual(metadata.vwt.extraInhabitantCount, 251)
    XCTAssertEqual(metadata.vwt.size, 1)
    XCTAssertEqual(metadata.vwt.stride, 1)
    XCTAssertEqual(metadata.vwt.flags.bits, 2097152)
    
    // Enum VWT
    
    withUnsafePointer(to: Colors.blue) {
      XCTAssertEqual(metadata.enumVwt.getEnumTag(for: $0), 1)
    }
  }
  
  static func testGenericEnum() throws {
    let maybeMetadata = reflectEnum(Colors2<Int>.self)
    XCTAssertNotNil(maybeMetadata)
    
    let metadata = maybeMetadata!
    
    XCTAssert(metadata.kind == .enum || metadata.kind == .optional)
    XCTAssertEqual(metadata.fieldOffsets, [])
    XCTAssert(typeArraysEquals(metadata.genericTypes, [Int.self]))
    
    // VWT
    
    XCTAssertEqual(metadata.vwt.extraInhabitantCount, 253)
    XCTAssertEqual(metadata.vwt.size, 9)
    XCTAssertEqual(metadata.vwt.stride, 16)
    XCTAssertEqual(metadata.vwt.flags.bits, 2162695)
    
    // Enum VWT
    
    withUnsafePointer(to: Colors2<Int>.blue(128)) {
      XCTAssertEqual(metadata.enumVwt.getEnumTag(for: $0), 0)
    }
  }
}

extension EchoTests {
  func testEnumMetadata() throws {
    try EnumMetadataTests.testEnum()
    try EnumMetadataTests.testGenericEnum()
  }
}
