import XCTest
import Echo

final class EchoTests: XCTestCase {
  static var allTests = [
    // Context Descriptors
    
    ("testAnonymousDescriptor", testAnonymousDescriptor),
    ("testClassDescriptor", testClassDescriptor),
    ("testEnumDescriptor", testEnumDescriptor),
    ("testExtensionDescriptor", testExtensionDescriptor),
    ("testFieldDescriptor", testFieldDescriptor),
    ("testGenericContext", testGenericContext),
    ("testModuleDescriptor", testModuleDescriptor),
    ("testProtocolDescriptor", testProtocolDescriptor),
    ("testStructDescriptor", testStructDescriptor),
    
    // Metadata
    
    ("testClassMetadata", testClassMetadata),
    ("testEnumMetadata", testEnumMetadata),
    ("testExistentialMetadata", testExistentialMetadata),
    ("testExistentialMetatypeMetadata", testExistentialMetatypeMetadata),
    ("testFunctionMetadata", testFunctionMetadata),
    ("testMetadataAccessFunction", testMetadataAccessFunction),
    ("testMetatypeMetadata", testMetatypeMetadata),
    ("testObjCClassWrapperMetadata", testObjCClassWrapperMetadata),
    ("testOpaqueMetadata", testOpaqueMetadata),
    ("testStructMetadata", testStructMetadata),
    ("testTupleMetadata", testTupleMetadata),
    
    // Runtime
    
    ("testConformanceDescriptor", testConformanceDescriptor),
    ("testExistentialContainer", testExistentialContainer),
    ("testImageInspection", testImageInspection),
  ]
}

