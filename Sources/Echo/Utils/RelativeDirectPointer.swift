//
//  RelativeDirectPointer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

struct RelativeDirectPointer<Pointee>: RelativePointer {
  let offset: Int32
  
  func pointee(from ptr: UnsafeRawPointer) -> Pointee? {
    if isNull {
      return nil
    }
    
    return address(from: ptr).load(as: Pointee.self)
  }
}

extension UnsafeRawPointer {
  func relativeDirectAddress<T>(as type: T.Type) -> UnsafeRawPointer {
    let relativePointer = RelativeDirectPointer<T>(
      offset: load(as: Int32.self)
    )
    return relativePointer.address(from: self)
  }
}
