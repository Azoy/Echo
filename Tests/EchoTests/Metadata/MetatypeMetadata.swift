import XCTest
import Echo

extension EchoTests {
  func testMetatypeMetadata() throws {
    let maybeMetadata = reflect(Int.Type.self) as? MetatypeMetadata
    XCTAssertNotNil(maybeMetadata)
    
    let metadata = maybeMetadata!
    
    XCTAssert(metadata.instanceType == Int.self)
    XCTAssertEqual(metadata.kind, .metatype)
    
    // VWT
    
    var extraInhabitantCount = 2147483647
    #if os(Linux)
    extraInhabitantCount = 4096
    #endif
    
    XCTAssertEqual(metadata.vwt.extraInhabitantCount, extraInhabitantCount)
    XCTAssertEqual(metadata.vwt.size, 8)
    XCTAssertEqual(metadata.vwt.stride, 8)
    XCTAssertEqual(metadata.vwt.flags.bits, 7)
  }
}
