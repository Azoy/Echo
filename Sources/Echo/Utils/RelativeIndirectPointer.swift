//
//  RelativeIndirectPointer.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

struct RelativeIndirectPointer<Pointee>: RelativePointer {
  let ptr: UnsafeRawPointer
  let offset: Int32
  var nullable = false
  
  func load<T>(as type: T.Type) -> T? {
    if nullable && offset == 0 {
      return nil
    }
    
    return address.load(as: UnsafePointer<T>.self).pointee
  }
}
