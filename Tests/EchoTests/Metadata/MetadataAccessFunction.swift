import XCTest
import Echo

struct FooBar0 {}
struct FooBar1<T> {}
struct FooBar2<T, U> {}
struct FooBar3<T, U, V> {}
struct FooBar4<T, U, V, W> {}

struct FooBaz1<T: Equatable> {}
struct FooBaz2<T: Equatable, U: Equatable> {}
struct FooBaz3<T: Equatable, U: Equatable, V: Equatable> {}
struct FooBaz4<T: Equatable, U: Equatable, V: Equatable, W: Equatable> {}

enum MetadataAccessFunctionTests {
  static func testPlain() throws {
    // 0 ARG
    
    let metadata0 = reflectStruct(FooBar0.self)!
    let accessor0 = metadata0.descriptor.accessor
    let response0 = accessor0(.complete)
    XCTAssertEqual(response0.state, .complete)
    XCTAssert(response0.type == FooBar0.self)
    
    // 1 ARG
    
    let metadata1 = reflectStruct(FooBar1<Int>.self)!
    let accessor1 = metadata1.descriptor.accessor
    let response1 = accessor1(.complete, Double.self)
    XCTAssertEqual(response1.state, .complete)
    XCTAssert(response1.type == FooBar1<Double>.self)
    
    // 2 ARG
    
    let metadata2 = reflectStruct(FooBar2<Int, Int>.self)!
    let accessor2 = metadata2.descriptor.accessor
    let response2 = accessor2(.complete, Double.self, Double.self)
    XCTAssertEqual(response2.state, .complete)
    XCTAssert(response2.type == FooBar2<Double, Double>.self)
    
    // 3 ARG
    
    let metadata3 = reflectStruct(FooBar3<Int, Int, Int>.self)!
    let accessor3 = metadata3.descriptor.accessor
    let response3 = accessor3(.complete, Double.self, Double.self, Double.self)
    XCTAssertEqual(response3.state, .complete)
    XCTAssert(response3.type == FooBar3<Double, Double, Double>.self)
    
    // 4 ARG
    
    let metadata4 = reflectStruct(FooBar4<Int, Int, Int, Int>.self)!
    let accessor4 = metadata4.descriptor.accessor
    let response4 = accessor4(.complete, Double.self, Double.self, Double.self, Double.self)
    XCTAssertEqual(response4.state, .complete)
    XCTAssert(response4.type == FooBar4<Double, Double, Double, Double>.self)
  }
  
  static func testWitnessTable() throws {
    let equatableMetadata = reflect(_typeByName("SQ")!) as! ExistentialMetadata
    let equatable = equatableMetadata.protocols[0]
    var doubleEquatable: WitnessTable? = nil
    
    let hashableMetadata = reflect(_typeByName("SH")!) as! ExistentialMetadata
    let hashable = hashableMetadata.protocols[0]
    var doubleHashable: WitnessTable? = nil
    
    for conformance in reflectStruct(Double.self)!.conformances {
      if conformance.protocol == equatable {
        XCTAssert(!conformance.flags.hasGenericWitnessTable)
        doubleEquatable = conformance.witnessTablePattern
      }
      
      if conformance.protocol == hashable {
        XCTAssert(!conformance.flags.hasGenericWitnessTable)
        doubleHashable = conformance.witnessTablePattern
      }
    }
    
    let typeWitness = (Double.self, doubleEquatable)
    let typeWitness1 = (Double.self, doubleHashable)
    
    // 1 ARG
    
    let metadata1 = reflectStruct(FooBaz1<Int>.self)!
    let accessor1 = metadata1.descriptor.accessor
    let response1 = accessor1(.complete, typeWitness)
    XCTAssertEqual(response1.state, .complete)
    XCTAssert(response1.type == FooBaz1<Double>.self)
    
    // 2 ARG
    
    let metadata2 = reflectStruct(FooBaz2<Int, Int>.self)!
    let accessor2 = metadata2.descriptor.accessor
    let response2 = accessor2(.complete, typeWitness, typeWitness)
    XCTAssertEqual(response2.state, .complete)
    XCTAssert(response2.type == FooBaz2<Double, Double>.self)
    
    // 3 ARG
    
    let metadata3 = reflectStruct(FooBaz3<Int, Int, Int>.self)!
    let accessor3 = metadata3.descriptor.accessor
    let response3 = accessor3(.complete, typeWitness, typeWitness, typeWitness)
    XCTAssertEqual(response3.state, .complete)
    XCTAssert(response3.type == FooBaz3<Double, Double, Double>.self)
    
    // 4 ARG
    
    let metadata4 = reflectStruct(FooBaz4<Int, Int, Int, Int>.self)!
    let accessor4 = metadata4.descriptor.accessor
    let response4 = accessor4(.complete, typeWitness, typeWitness, typeWitness, typeWitness)
    XCTAssertEqual(response4.state, .complete)
    XCTAssert(response4.type == FooBaz4<Double, Double, Double, Double>.self)
    
    // STDLIB TYPES
    
    let dictMetadata = reflectStruct([Int: Int].self)!
    let dictAccessor = dictMetadata.descriptor.accessor
    // The last argument has a nil witness table because the value type in
    // dictionary has no conformance requirements.
    let dictResponse = dictAccessor(.complete, typeWitness1, (Double.self, nil))
    XCTAssertEqual(dictResponse.state, .complete)
    XCTAssert(dictResponse.type == [Double: Double].self)
  }
}

extension EchoTests {
  func testMetadataAccessFunction() throws {
    try MetadataAccessFunctionTests.testPlain()
    try MetadataAccessFunctionTests.testWitnessTable()
  }
}
