//
//  EnumDescriptor.swift
//  EchoTests
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import XCTest
import Echo

enum Colors {
  case blue
  case red
  case yellow
  case green(Bool)
}

extension EchoTests {
  func testEnumDescriptor() {
    let metadata = reflect(Colors.self) as! EnumMetadata
    XCTAssertEqual(metadata.descriptor.numEmptyCases, 3)
    XCTAssertEqual(metadata.descriptor.numPayloadCases, 1)
    XCTAssertEqual(metadata.descriptor.numCases, 4)
    
    let blue = Colors.blue
    something(with: blue)
  }
  
  func something(with: Any) {
    var container = unsafeBitCast(with, to: ExistentialContainer.self)
    print(container.metadata.enumVwt.getEnumTag(for: container.projectValue()))
    print(container.data)
  }
}

