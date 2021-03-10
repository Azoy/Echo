import XCTest
import Echo

extension EchoTests {
  func testTupleMetadata() throws {
    let maybeMetadata = reflect((Int, String).self) as? TupleMetadata
    XCTAssertNotNil(maybeMetadata)
    
    let metadata = maybeMetadata!
    
    XCTAssertEqual(metadata.numElements, 2)
    
    for i in 0 ..< metadata.numElements {
      switch i {
      case 0:
        XCTAssertEqual(metadata.labels[i], "0")
        XCTAssert(metadata.elements[i].type == Int.self)
        XCTAssertEqual(metadata.elements[i].offset, 0)
      case 1:
        XCTAssertEqual(metadata.labels[i], "1")
        XCTAssert(metadata.elements[i].type == String.self)
        XCTAssertEqual(metadata.elements[i].offset, MemoryLayout<Int>.size)
      default:
        fatalError()
      }
    }
    
    // LABELS
    
    let _metadata = reflect((age: Int, name: String).self) as! TupleMetadata
    XCTAssertEqual(_metadata.labels, ["age", "name"])
    
    // VWT
    
    var extraInhabitantCount = 2147483647
    #if os(Linux)
    extraInhabitantCount = 4096
    #endif
    
    XCTAssertEqual(metadata.vwt.extraInhabitantCount, extraInhabitantCount)
    XCTAssertEqual(metadata.vwt.size, 24)
    XCTAssertEqual(metadata.vwt.stride, 24)
    XCTAssertEqual(metadata.vwt.flags.bits, 65543)
  }
}
