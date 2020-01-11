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
  
  func address(from ptr: UnsafeRawPointer) -> UnsafePointer<Pointee> {
    UnsafePointer<Pointee>(ptr + Int((offset & ~intMask) & ~1))
  }
  
  func pointee(from ptr: UnsafeRawPointer) -> Pointee? {
    if offset == 0 {
      return nil
    }
    
    if Int(offset) & 1 == 1 {
      let pointer = address(from: ptr).raw.load(as: UnsafePointer<Pointee>.self)
      return pointer.pointee
    } else {
      return address(from: ptr).pointee
    }
  }
}

extension UnsafeRawPointer {
  func relativeIndirectableIntPairAddress<T, U: FixedWidthInteger>(
    as type: T.Type,
    and typ2: U.Type
  ) -> UnsafePointer<T> {
    let relativePointer = RelativeIndirectablePointerIntPair<T, U>(
      offset: load(as: Int32.self)
    )
    return relativePointer.address(from: self)
  }
}
