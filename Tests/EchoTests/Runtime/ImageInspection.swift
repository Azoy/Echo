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
  
  static func testProtos() throws {
    let protos = Echo.protocols
    
    // Echo Protos
    
    var echoFound = false
    for proto in protos {
      guard let module = proto.parent as? ModuleDescriptor else {
        continue
      }
      
      guard module.name == "Echo", proto.name == "Metadata" else {
        continue
      }
      
      echoFound = true
    }
    
    XCTAssertTrue(echoFound)
    
    // Stdlib protos
    
    var stdlibFound = false
    for proto in protos {
      guard let module = proto.parent as? ModuleDescriptor else {
        continue
      }
      
      guard module.name == "Swift", proto.name == "RandomNumberGenerator" else {
        continue
      }
      
      stdlibFound = true
    }
    
    XCTAssertTrue(stdlibFound)
  }
  
  static func testTypes() throws {
    let types = Echo.types
    
    // Echo Protos
    
    var echoFound = false
    for type in types {
      guard let module = type.parent as? ModuleDescriptor else {
        continue
      }
      
      guard let structDescriptor = type as? StructDescriptor else {
        continue
      }
      
      guard module.name == "Echo", structDescriptor.name == "StructMetadata" else {
        continue
      }
      
      echoFound = true
    }
    
    XCTAssertTrue(echoFound)
    
    // Stdlib protos
    
    var stdlibFound = false
    for type in types {
      guard let module = type.parent as? ModuleDescriptor else {
        continue
      }
      
      guard let structDescriptor = type as? StructDescriptor else {
        continue
      }
      
      guard module.name == "Swift", structDescriptor.name == "Int" else {
        continue
      }
      
      stdlibFound = true
    }
    
    XCTAssertTrue(stdlibFound)
  }
}

extension EchoTests {
  func testImageInspection() throws {
    try ImageInspectionTests.testConformances()
    try ImageInspectionTests.testProtos()
    try ImageInspectionTests.testTypes()
  }
}
