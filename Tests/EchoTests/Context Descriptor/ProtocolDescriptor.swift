import XCTest
import Echo

protocol Testing {
  associatedtype Hello
  associatedtype World
  
  var name: String { get set }
  
  func sayHello() -> String
}

extension EchoTests {
  func testProtocolDescriptor() throws {
    // Can't reference protocols with associatedtypes yet (!)
    let metadata = reflect(_typeByName("9EchoTests7TestingP")!) as! ExistentialMetadata
    let proto = metadata.protocols[0]
    
    XCTAssertEqual(proto.associatedTypeNames, "Hello World")
    XCTAssertEqual(proto.name, "Testing")
    XCTAssertEqual(proto.numRequirements, 6)
    XCTAssertEqual(proto.numRequirementsInSignature, 0)
    XCTAssertEqual(proto.protocolFlags.bits, 1)
    XCTAssertEqual(proto.requirementSignature.count, 0)
    
    for (i, requirement) in proto.requirements.enumerated() {
      switch i {
      case 0:
        XCTAssertEqual(requirement.flags.bits, 7)
      case 1:
        XCTAssertEqual(requirement.flags.bits, 7)
      case 2:
        XCTAssertEqual(requirement.flags.bits, 19)
      case 3:
        XCTAssertEqual(requirement.flags.bits, 20)
      case 4:
        XCTAssertEqual(requirement.flags.bits, 22)
      case 5:
        XCTAssertEqual(requirement.flags.bits, 17)
      default:
        break
      }
    }
  }
}
