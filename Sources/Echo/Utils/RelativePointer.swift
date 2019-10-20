//
//  RelativePointer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

protocol RelativePointer {
  associatedtype Pointee
  
  var offset: Int32 { get }
  
  func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer
  func load<T>(from ptr: UnsafeRawPointer, as type: T.Type) -> T?
  func pointee(from ptr: UnsafeRawPointer) -> Pointee?
}

extension RelativePointer {
  func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer {
    ptr.advanced(by: Int(offset))
  }
  
  func pointee(from ptr: UnsafeRawPointer) -> Pointee? {
    load(from: ptr, as: Pointee.self)
  }
}
