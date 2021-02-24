import XCTest
import Echo

struct ExtensionFoo<T> {}

// Must be generic extension to trigger unique descriptor
extension ExtensionFoo where T == Int {
  struct ExtensionBar {}
}

extension EchoTests {
  func testExtensionDescriptor() {
    let metadata = reflectStruct(ExtensionFoo<Int>.ExtensionBar.self)!
    let extensionDescriptor = metadata.descriptor.parent as! ExtensionDescriptor
    let extendedContext = extensionDescriptor.extendedContext
    
    let size = getSymbolicMangledNameLength(extendedContext)
    // 9 because symbolic prefix (1), symbol (4), ySiG (4)
    // where ySiG is binding the type to <Int>
    XCTAssertEqual(size, 9)
  }
}

