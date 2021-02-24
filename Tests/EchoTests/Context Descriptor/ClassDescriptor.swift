import XCTest
import Echo

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
    let metadata = reflectClass(Super.self)!
    let descriptor = metadata.descriptor
    XCTAssertEqual(descriptor.superclass.load(as: CChar.self), 0) // nullptr
    XCTAssertEqual(descriptor.numFields, 1)
    XCTAssertEqual(descriptor.numMembers, 3) // name, init, sayHello
    XCTAssertEqual(descriptor.fieldOffsetVectorOffset, 10)
    
    let child = reflectClass(Child.self)!
    let size = getSymbolicMangledNameLength(child.descriptor.superclass)
    // 5 because symbolic prefix (1), symbol (4)
    XCTAssertEqual(size, 5)
    XCTAssertEqual(child.descriptor.numFields, 0)
    XCTAssertEqual(child.descriptor.numMembers, 0)
    XCTAssertEqual(child.descriptor.fieldOffsetVectorOffset, 13)
  }
}

