import XCTest
import Echo

extension EchoTests {
  func testOpaqueMetadata() throws {
    let int128 = Echo.KnownMetadata.Builtin.int128
    let int512 = Echo.KnownMetadata.Builtin.int512
    XCTAssertFalse(int128 == int512)
    XCTAssertEqual(int128.kind, .opaque)
    
    // VWT
    
    XCTAssertEqual(int512.vwt.extraInhabitantCount, 0)
    XCTAssertEqual(int512.vwt.size, 64)
    XCTAssertEqual(int512.vwt.stride, 64)
    XCTAssertEqual(int512.vwt.flags.bits, 131087)
  }
}
