//
//  RelativeDirectPointer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

struct RelativeDirectPointer<Pointee>: RelativePointer {
  let offset: Int32
  
  func load<T>(from ptr: UnsafeRawPointer, as type: T.Type) -> T? {
    if offset == 0 {
      return nil
    }
    
    return address(from: ptr).load(as: T.self)
  }
}
