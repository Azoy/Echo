import XCTest
import Echo

enum ImageInspectionTests {
  static func testConformances() throws {
    // Echo Types
    
    let metadata = reflectStruct(StructMetadata.self)!
    XCTAssertEqual(metadata.conformances.count, 4)
    
    // Stdlib types
    
    let int = reflectStruct(Int.self)!
    
    var intConfCount = 27
    #if os(Linux)
    intConfCount = 25
    #endif
    
    XCTAssert(int.conformances.count >= intConfCount)
  }
}

extension EchoTests {
  func testImageInspection() throws {
    try ImageInspectionTests.testConformances()
  }
}
