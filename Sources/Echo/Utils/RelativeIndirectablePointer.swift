//
//  RelativeIndirectablePointer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

struct RelativeIndirectablePointer<Pointee>: RelativePointer {
  let offset: Int32
  
  func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer {
    let start = ptr + Int(offset & ~1)
    
    if Int(offset) & 1 == 1 {
      return start.load(as: UnsafeRawPointer.self)
    } else {
      return start
    }
  }
  
  func pointee(from ptr: UnsafeRawPointer) -> Pointee? {
    if isNull {
      return nil
    }
    
    return address(from: ptr).load(as: Pointee.self)
  }
}
