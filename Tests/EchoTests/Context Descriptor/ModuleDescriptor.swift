import XCTest
import Echo

extension EchoTests {
  func testModuleDescriptor() throws {
    let metadata = reflectStruct(Int.self)!
    let module = try XCTUnwrap(metadata.descriptor.parent) as? ModuleDescriptor
    XCTAssertNotNil(module)
    XCTAssertEqual(module!.name, "Swift")
    XCTAssertNil(module?.parent)
  }
}

