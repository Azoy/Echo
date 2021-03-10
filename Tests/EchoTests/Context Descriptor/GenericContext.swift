import XCTest
import Echo

struct Cat3<T, U: Equatable> {}

enum GenericContextTests {
  static func testNoRequirements() throws {
    let metadata = reflectStruct(Cat2<Int, String>.self)!
    XCTAssert(metadata.descriptor.flags.isGeneric)
    let gc = metadata.descriptor.genericContext!
    
    XCTAssertEqual(gc.numExtraArguments, 0)
    XCTAssertEqual(gc.numKeyArguments, 2)
    XCTAssertEqual(gc.numParams, 2)
    XCTAssertEqual(gc.numRequirements, 0)
    XCTAssertEqual(gc.size, 12)
    XCTAssertEqual(gc.parameters.map { $0.bits }, [128, 128])
    XCTAssertEqual(gc.requirements.count, 0)
    
    // TYPE
    
    let typeGc = metadata.descriptor.typeGenericContext
    XCTAssertEqual(typeGc.size, 20)
    XCTAssertEqual(typeGc.genericMetadataPattern.flags.bits, 1073741824)
  }
  
  static func testRequirements() throws {
    let metadata = reflectStruct(Cat3<Int, String>.self)!
    XCTAssert(metadata.descriptor.flags.isGeneric)
    let gc = metadata.descriptor.genericContext!
    
    XCTAssertEqual(gc.numExtraArguments, 0)
    XCTAssertEqual(gc.numKeyArguments, 3)
    XCTAssertEqual(gc.numParams, 2)
    XCTAssertEqual(gc.numRequirements, 1)
    XCTAssertEqual(gc.size, 24)
    XCTAssertEqual(gc.parameters.map { $0.bits }, [128, 128])
    XCTAssertEqual(gc.requirements.count, 1)
    
    for (i, requirement) in gc.requirements.enumerated() {
      switch i {
      case 0:
        XCTAssert(requirement.flags.kind == .protocol)
        XCTAssertEqual(requirement.protocol.name, "Equatable")
      default:
        break
      }
    }
    
    // TYPE
    
    let typeGc = metadata.descriptor.typeGenericContext
    XCTAssertEqual(typeGc.size, 32)
    XCTAssertEqual(typeGc.genericMetadataPattern.flags.bits, 1073741824)
  }
}

extension EchoTests {
  func testGenericContext() throws {
    try GenericContextTests.testNoRequirements()
    try GenericContextTests.testRequirements()
  }
}
