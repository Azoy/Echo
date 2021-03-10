import XCTest
import Echo

protocol Testable {}
protocol Testable2 {}

extension EchoTests {
  func testExistentialMetadata() throws {
    let maybeMetadata = reflect(Testable.self) as? ExistentialMetadata
    XCTAssertNotNil(maybeMetadata)
    
    let metadata = maybeMetadata!
    
    XCTAssertEqual(metadata.flags.bits, 2147483649)
    XCTAssertEqual(metadata.numProtocols, 1)
    XCTAssertNil(metadata.superclass)
    XCTAssertEqual(metadata.kind, .existential)
    
    // VWT
    
    var extraInhabitantCount = 2147483647
    #if os(Linux)
    extraInhabitantCount = 4096
    #endif
    
    XCTAssertEqual(metadata.vwt.extraInhabitantCount, extraInhabitantCount)
    XCTAssertEqual(metadata.vwt.size, 40)
    XCTAssertEqual(metadata.vwt.stride, 40)
    XCTAssertEqual(metadata.vwt.flags.bits, 196615)
    
    // Dual Existential
    
    let maybeMetadata2 = reflect((Testable & Testable2).self) as? ExistentialMetadata
    XCTAssertNotNil(maybeMetadata2)
    
    let metadata2 = maybeMetadata2!
    
    XCTAssertEqual(metadata2.flags.bits, 2147483650)
    XCTAssertEqual(metadata2.numProtocols, 2)
    XCTAssertNil(metadata2.superclass)
    XCTAssertEqual(metadata2.kind, .existential)
    
    // VWT
    
    XCTAssertEqual(metadata2.vwt.extraInhabitantCount, extraInhabitantCount)
    XCTAssertEqual(metadata2.vwt.size, 48)
    XCTAssertEqual(metadata2.vwt.stride, 48)
    XCTAssertEqual(metadata2.vwt.flags.bits, 196615)
  }
}
