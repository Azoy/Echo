//
//  AnonymousDescriptor.swift
//  EchoTests
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import XCTest
import Echo

struct AnonymousFoo {
  private struct AnonymousBar {}
  private struct AnonymousGenericBar<T: Equatable> {}
  
  static func test() throws {
    let metadata = reflect(AnonymousBar.self) as! StructMetadata
    let parent = metadata.descriptor.parent! as! AnonymousDescriptor
    XCTAssertTrue(parent.anonymousFlags.hasMangledName)
    let mangledName = try XCTUnwrap(parent.mangledName)
    XCTAssertEqual(
      mangledName,
      "$s9EchoTests12AnonymousFooV0C3Bar33_16BDE84827F25937B00C6B35A30DC536LLV"
    )
  }
  
  static func testGeneric() throws {
    let metadata = reflect(AnonymousGenericBar<Int>.self) as! StructMetadata
    let parent = metadata.descriptor.parent! as! AnonymousDescriptor
    XCTAssertTrue(parent.anonymousFlags.hasMangledName)
    let mangledName = try XCTUnwrap(parent.mangledName)
    XCTAssertEqual(
      mangledName,
      "$s9EchoTests12AnonymousFooV0C10GenericBar33_16BDE84827F25937B00C6B35A30DC536LLV"
    )
  }
}

extension EchoTests {
  func testAnonymousDescriptor() throws {
    try AnonymousFoo.test()
    try AnonymousFoo.testGeneric()
  }
}
