//
//  FieldType.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

// This isn't used anywhere yet... ?
public struct FieldType {
  public let bits: UInt
  
  public var isIndirect: Bool {
    bits & 0x1 == 0x1
  }
  
  public var isWeak: Bool {
    bits & 0x2 == 0x2
  }
  
  var metadataPtr: UnsafeRawPointer {
    let typeMask = UInt.max & ~UInt(MemoryLayout<UnsafeRawPointer>.alignment - 1)
    return UnsafeRawPointer(bitPattern: bits & typeMask)!
  }
  
  public var metadata: Metadata {
    getMetadata(at: metadataPtr)
  }
  
  public var type: Any.Type {
    metadata.type
  }
}
