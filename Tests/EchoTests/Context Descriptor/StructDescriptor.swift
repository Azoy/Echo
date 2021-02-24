import XCTest
import Echo

struct Dog {
  let name: String
  let age: Int
}

extension EchoTests {
  func testStructDescriptor() throws {
    let metadata = reflectStruct(Dog.self)!
    let descriptor = metadata.descriptor
    XCTAssertEqual(descriptor.numFields, 2)
    XCTAssertEqual(descriptor.fieldOffsetVectorOffset, 2)
    XCTAssertNil(descriptor.foreignMetadataInitialization)
    XCTAssertNil(descriptor.singletonMetadataInitialization)
  }
}

