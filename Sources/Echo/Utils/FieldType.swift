//
//  FieldType.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

// This isn't used anywhere yet... ?
struct FieldType {
  public let bits: UInt
  
  public var isIndirect: Bool {
    bits & 0x1 != 0
  }
  
  public var isWeak: Bool {
    bits & 0x2 != 0
  }
  
  public var metadata: Metadata {
    reflect(type)
  }
  
  public var type: Any.Type {
    let typeMask = UInt.max & ~UInt(MemoryLayout<UnsafeRawPointer>.alignment - 1)
    let address = UnsafeRawPointer(bitPattern: bits & typeMask)!
    return unsafeBitCast(address, to: Any.Type.self)
  }
}
