//
//  RelativeIndirectablePointerIntPair.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

struct RelativeIndirectablePointerIntPair<
  Pointee,
  IntTy: FixedWidthInteger
>: RelativePointer {
  let offset: Int32
  
  var intMask: Int32 {
    Int32(MemoryLayout<Int32>.alignment - 1) & ~0x1
  }
  
  var int: IntTy {
    IntTy(offset & intMask) >> 1
  }
  
  var isSet: Bool {
    int & 1 != 0
  }
  
  func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer {
    ptr + Int((offset & ~intMask) & ~1)
  }
  
  func load<T>(from ptr: UnsafeRawPointer, as type: T.Type) -> T? {
    if offset == 0 {
      return nil
    }
    
    if Int(offset) & 1 == 1 {
      return address(from: ptr).load(as: UnsafePointer<T>.self).pointee
    } else {
      return address(from: ptr).load(as: T.self)
    }
  }
}
