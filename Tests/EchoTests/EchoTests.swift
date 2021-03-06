import XCTest
import Echo

final class EchoTests: XCTestCase {
  static var allTests = [
    // Metadata
    
    ("testMetadataAccessFunction", testMetadataAccessFunction),
    ("testStructMetadata", testStructMetadata),
    
    // Context Descriptors
    
    ("testAnonymousDescriptor", testAnonymousDescriptor),
    ("testClassDescriptor", testClassDescriptor),
    ("testEnumDescriptor", testEnumDescriptor),
    ("testModuleDescriptor", testModuleDescriptor),
    ("testExtensionDescriptor", testExtensionDescriptor),
    ("testStructDescriptor", testStructDescriptor),
    ("testFieldDescriptor", testFieldDescriptor)
  ]
}

