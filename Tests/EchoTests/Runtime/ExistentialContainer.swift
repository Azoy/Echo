import XCTest
import Echo

extension EchoTests {
  func testExistentialContainer() throws {
    // NO WITNESS TABLE
    
    let x: Any = 128
    var xBox = container(for: x)
    let dataPtr = xBox.projectValue()
    
    XCTAssert(xBox.type == Int.self)
    XCTAssertEqual(dataPtr.load(as: Int.self), 128)
    
    // SINGLE WITNESS TABLE
    
    let y: Wheel = CheeseWheel()
    var yBox = unsafeBitCast(y, to: ExistentialContainer.self)
    let yPtr = yBox.base.projectValue()
    
    XCTAssert(yBox.base.type == CheeseWheel.self)
    XCTAssertEqual(yPtr.load(as: CheeseWheel.self), CheeseWheel())
    XCTAssertEqual(yBox.witnessTable.conformanceDescriptor.protocol.name, "Wheel")
    
    // DUAL WITNESS TABLE
    
    let z: Wheel & DumbWheel = CheeseWheel()
    var zBox = unsafeBitCast(z, to: DualExistentialContainer.self)
    let zPtr = zBox.base.projectValue()
    
    XCTAssert(zBox.base.type == CheeseWheel.self)
    XCTAssertEqual(zPtr.load(as: CheeseWheel.self), CheeseWheel())
    XCTAssertEqual(zBox.witnessTables.0.conformanceDescriptor.protocol.name, "DumbWheel")
    XCTAssertEqual(zBox.witnessTables.1.conformanceDescriptor.protocol.name, "Wheel")
    
    // Wrapped existentials
    
    func wrap<T>(_ x: T) -> Any {
      x
    }
    
    let wrapped = wrap(wrap(wrap(wrap(128))))
    var wrappedBox = container(for: wrapped)
    let wrappedPtr = wrappedBox.projectValue()
    XCTAssert(wrappedBox.type == Int.self)
    XCTAssertEqual(wrappedPtr.load(as: Int.self), 128)
  }
}
