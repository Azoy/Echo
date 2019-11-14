//
//  RelativeIndirectablePointer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

struct RelativeIndirectablePointer<Pointee>: RelativePointer {
  let offset: Int32
  
  func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer {
    ptr + Int(offset & ~1)
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
