//
//  RelativePointer.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

protocol RelativePointer {
  associatedtype Pointee
  
  var ptr: UnsafeRawPointer { get }
  var offset: Int32 { get }
  var nullable: Bool { get }
  var address: UnsafeRawPointer { get }
  var pointee: Pointee? { get }
  
  func load<T>(as type: T.Type) -> T?
}

extension RelativePointer {
  var address: UnsafeRawPointer {
    ptr.advanced(by: Int(offset))
  }
  
  var pointee: Pointee? {
    load(as: Pointee.self)
  }
}
