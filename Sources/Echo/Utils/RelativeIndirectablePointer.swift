//
//  RelativeIndirectablePointer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

struct RelativeIndirectablePointer<Pointee>: RelativePointer {
  let offset: Int32
  
  func address(from ptr: UnsafeRawPointer) -> UnsafePointer<Pointee> {
    UnsafePointer<Pointee>(ptr + Int(offset & ~1))
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
