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
    let metadata = reflect(Colors.self) as! EnumMetadata
    XCTAssertEqual(metadata.descriptor.numEmptyCases, 3)
    XCTAssertEqual(metadata.descriptor.numPayloadCases, 1)
  }
}

