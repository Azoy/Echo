import XCTest
import Echo

enum FieldDescriptorTests {
  
  class FieldTesting {
    weak var superman: Super?
    unowned let child1: Child
    unowned(unsafe) let child2: Child
    
    init(child1: Child, child2: Child) {
      self.child1 = child1
      self.child2 = child2
    }
  }
  
  static func testClass() throws {
    let metadata = reflectClass(FieldTesting.self)!
    let fields = metadata.descriptor.fields
    
    XCTAssert(fields.hasMangledTypeName)
    XCTAssertEqual(fields.kind, .class)
    
    let typeName = metadata.type(of: fields.mangledTypeName)!
    XCTAssert(typeName == FieldTesting.self)
    
    XCTAssertEqual(fields.numFields, 3)
    
    XCTAssertEqual(fields.recordSize, 12)
    for (i, record) in fields.records.enumerated() {
      XCTAssert(record.hasMangledTypeName)
      
      let varType = metadata.type(of: record.mangledTypeName)!
      
      switch i {
      case 0:
        XCTAssert(varType == Super?.self)
      case 1...2:
        XCTAssert(varType == Child.self)
      default:
        break
      }
      
      switch i {
      case 0:
        XCTAssertEqual(record.referenceStorage, .weak)
        XCTAssert(record.flags.isVar)
      case 1:
        XCTAssertEqual(record.referenceStorage, .unowned)
        XCTAssertFalse(record.flags.isVar)
      case 2:
        XCTAssertEqual(record.referenceStorage, .unmanaged)
        XCTAssertFalse(record.flags.isVar)
      default:
        break
      }
      
      XCTAssertFalse(record.flags.isIndirectCase)
    }
  }
  
  enum ABC {
    case a, b, c
  }
  
  enum Color {
    indirect case color(Color)
    case hue(String)
  }
  
  static func testEnum() throws {
    let metadata = reflectEnum(ABC.self)!
    let fields = metadata.descriptor.fields
    
    XCTAssert(fields.hasMangledTypeName)
    XCTAssertEqual(fields.kind, .enum)
    
    let typeName = metadata.type(of: fields.mangledTypeName)!
    XCTAssert(typeName == ABC.self)
    
    XCTAssertEqual(fields.numFields, 3)
    
    XCTAssertEqual(fields.recordSize, 12)
    for record in fields.records {
      XCTAssertFalse(record.hasMangledTypeName)
      XCTAssertEqual(record.referenceStorage, .none)
    }
    
    let colorMetadata = reflectEnum(Color.self)!
    let colorFields = colorMetadata.descriptor.fields
    
    XCTAssertEqual(colorFields.kind, .multiPayloadEnum)
    
    for (i, record) in colorFields.records.enumerated() {
      switch i {
      case 0:
        XCTAssert(record.flags.isIndirectCase)
        XCTAssertFalse(record.flags.isVar)
      case 1:
        XCTAssertFalse(record.flags.isIndirectCase)
        XCTAssertFalse(record.flags.isVar)
      default:
        break
      }
    }
    
  }
  
  static func testStruct() throws {
    let metadata = reflectStruct(Dog.self)!
    let fields = metadata.descriptor.fields
    
    XCTAssert(fields.hasMangledTypeName)
    XCTAssertEqual(fields.kind, .struct)
    
    let typeName = metadata.type(of: fields.mangledTypeName)!
    XCTAssert(typeName == Dog.self)
    
    XCTAssertEqual(fields.numFields, 2)
    
    XCTAssertEqual(fields.recordSize, 12)
    for (i, record) in fields.records.enumerated() {
      XCTAssert(record.hasMangledTypeName)
      
      let varType = metadata.type(of: record.mangledTypeName)!
      
      switch i {
      case 0:
        XCTAssert(varType == String.self)
      case 1:
        XCTAssert(varType == Int.self)
      default:
        break
      }
      
      XCTAssertEqual(record.referenceStorage, .none)
      XCTAssertFalse(record.flags.isIndirectCase)
      XCTAssertFalse(record.flags.isVar)
    }
  }
}

extension EchoTests {
  func testFieldDescriptor() throws {
    try FieldDescriptorTests.testClass()
    try FieldDescriptorTests.testEnum()
    try FieldDescriptorTests.testStruct()
  }
}

