//
//  RelativeIndirectablePointer.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

struct RelativeIndirectablePointer<Pointee>: RelativePointer {
  let offset: Int32
  
  func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer {
    ptr.advanced(by: Int(offset & ~1))
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
