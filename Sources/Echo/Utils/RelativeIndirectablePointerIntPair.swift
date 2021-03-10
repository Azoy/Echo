//
//  RelativeIndirectablePointerIntPair.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
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
    let offsetIndirect = offset & ~intMask
    let addr = ptr + Int(offsetIndirect & ~1)
    
    if Int(offsetIndirect) & 1 == 1 {
      return addr.load(as: UnsafeRawPointer.self)
    } else {
      return addr
    }
  }
  
  func pointee(from ptr: UnsafeRawPointer) -> Pointee? {
    if isNull {
      return nil
    }
    
    return address(from: ptr).load(as: Pointee.self)
  }
}

extension UnsafeRawPointer {
  func relativeIndirectableIntPairAddress<T, U: FixedWidthInteger>(
    as type: T.Type,
    and typ2: U.Type
  ) -> UnsafeRawPointer {
    let relativePointer = RelativeIndirectablePointerIntPair<T, U>(
      offset: load(as: Int32.self)
    )
    return relativePointer.address(from: self)
  }
}
