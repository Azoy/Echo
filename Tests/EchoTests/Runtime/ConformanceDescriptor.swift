import XCTest
import Echo

protocol Wheel {}
protocol DumbWheel {}

struct CheeseWheel: Wheel {}
extension CheeseWheel: Equatable {}
extension CheeseWheel: DumbWheel {}

extension EchoTests {
  func testConformanceDescriptor() throws {
    let metadata = reflectStruct(CheeseWheel.self)!
    let wheelConf = metadata.conformances[0]
    
    XCTAssertNotNil(wheelConf.contextDescriptor)
    #if canImport(ObjectiveC)
    XCTAssertNil(wheelConf.objcClass)
    #endif
    XCTAssertEqual(wheelConf.flags.bits, 0)
    XCTAssertEqual(wheelConf.protocol.name, "Wheel")
  }
}
