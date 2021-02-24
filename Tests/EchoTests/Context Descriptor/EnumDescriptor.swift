import XCTest
import Echo

enum Colors {
  case blue
  case red
  case yellow
  case green(Bool)
}

extension EchoTests {
  func testEnumDescriptor() {
    let metadata = reflectEnum(Colors.self)!
    XCTAssertEqual(metadata.descriptor.numEmptyCases, 3)
    XCTAssertEqual(metadata.descriptor.numPayloadCases, 1)
  }
}

