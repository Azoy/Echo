import XCTest
@testable import Echo

class Super {
  let name: String
  
  init(name: String) {
    self.name = name
  }
  
  func sayHello() {}
}

class Child: Super {}

extension EchoTests {
  func testClassDescriptor() {
    let metadata = reflect(Super.self) as! ClassMetadata
    XCTAssertEqual(metadata.descriptor.superclass.pointee, 0) // nullptr
    XCTAssertEqual(metadata.descriptor.numFields, 1)
    XCTAssertEqual(metadata.descriptor.numMembers, 3) // name, init, sayHello
    XCTAssertEqual(metadata.descriptor.fieldOffsetVectorOffset, 10)
    
    let child = reflect(Child.self) as! ClassMetadata
    let size = getSymbolicMangledNameLength(child.descriptor.superclass.raw)
    // 5 because symbolic prefix (1), symbol (4)
    XCTAssertEqual(size, 5)
    XCTAssertEqual(child.descriptor.numFields, 0)
    XCTAssertEqual(child.descriptor.numMembers, 0)
    XCTAssertEqual(child.descriptor.fieldOffsetVectorOffset, 13)
  }
}

