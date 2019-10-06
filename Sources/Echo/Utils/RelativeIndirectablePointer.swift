//
//  RelativeIndirectablePointer.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

struct RelativeIndirectablePointer<Pointee>: RelativePointer {
  let ptr: UnsafeRawPointer
  let offset: Int32
  var nullable = false
  
  var address: UnsafeRawPointer {
    ptr.advanced(by: Int(offset) & ~1)
  }
  
  func load<T>(as type: T.Type) -> T? {
    if nullable && offset == 0 {
      return nil
    }
    
    if Int(offset) & 1 == 1 {
      return address.load(as: UnsafePointer<T>.self).pointee
    } else {
      return address.load(as: T.self)
    }
  }
}
