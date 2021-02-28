import XCTest
import Echo

struct Cat {
  let name: String
  let age: Int
}

struct Cat2<T, U> {
  let name: T
  let age: U
}

enum StructMetadataTests {
  static func testStruct() throws {
    let maybeMetadata = reflectStruct(Cat.self)
    XCTAssertNotNil(maybeMetadata)
    
    let metadata = maybeMetadata!
    
    XCTAssertEqual(metadata.fieldOffsets, [0, 16])
    XCTAssert(typeArraysEquals(metadata.genericTypes, []))
    XCTAssertEqual(metadata.kind, .struct)
    XCTAssert(metadata.type == Cat.self)
    
    // VWT
    
    var extraInhabitantCount = 2147483647
    #if os(Linux)
    extraInhabitantCount = 4096
    #endif
    
    XCTAssertEqual(metadata.vwt.extraInhabitantCount, extraInhabitantCount)
    XCTAssertEqual(metadata.vwt.size, 24)
    XCTAssertEqual(metadata.vwt.stride, 24)
    XCTAssertEqual(metadata.vwt.flags.alignment, 8)
    XCTAssertEqual(metadata.vwt.flags.hasEnumWitnesses, false)
    XCTAssertEqual(metadata.vwt.flags.isBitwiseTakable, true)
    XCTAssertEqual(metadata.vwt.flags.isIncomplete, false)
    XCTAssertEqual(metadata.vwt.flags.isPOD, false)
    XCTAssertEqual(metadata.vwt.flags.isValueInline, true)
    
    // type(of:)
    
    for (i, record) in metadata.descriptor.fields.records.enumerated() {
      XCTAssert(record.hasMangledTypeName)
      
      switch i {
      case 0:
        XCTAssert(metadata.type(of: record.mangledTypeName) == String.self)
      case 1:
        XCTAssert(metadata.type(of: record.mangledTypeName) == Int.self)
      default:
        fatalError()
      }
    }
  }
  
  static func testGenericStruct() throws {
    let maybeMetadata = reflectStruct(Cat2<String, Int>.self)
    XCTAssertNotNil(maybeMetadata)
    
    let metadata = maybeMetadata!
    
    XCTAssertEqual(metadata.fieldOffsets, [0, 16])
    XCTAssert(typeArraysEquals(metadata.genericTypes, [String.self, Int.self]))
    XCTAssertEqual(metadata.kind, .struct)
    XCTAssert(metadata.type == Cat2<String, Int>.self)
    
    // VWT
    
    var extraInhabitantCount = 2147483647
    #if os(Linux)
    extraInhabitantCount = 4096
    #endif
    
    XCTAssertEqual(metadata.vwt.extraInhabitantCount, extraInhabitantCount)
    XCTAssertEqual(metadata.vwt.size, 24)
    XCTAssertEqual(metadata.vwt.stride, 24)
    XCTAssertEqual(metadata.vwt.flags.alignment, 8)
    XCTAssertEqual(metadata.vwt.flags.hasEnumWitnesses, false)
    XCTAssertEqual(metadata.vwt.flags.isBitwiseTakable, true)
    XCTAssertEqual(metadata.vwt.flags.isIncomplete, false)
    XCTAssertEqual(metadata.vwt.flags.isPOD, false)
    XCTAssertEqual(metadata.vwt.flags.isValueInline, true)
  }
}

extension EchoTests {
  func testStructMetadata() throws {
    try StructMetadataTests.testStruct()
    try StructMetadataTests.testGenericStruct()
  }
}

