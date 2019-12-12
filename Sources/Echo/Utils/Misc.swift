//
//  Misc.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

extension _Pointer {
  var raw: UnsafeRawPointer {
    UnsafeRawPointer(_rawValue)
  }
  
  // I mean, let's be honest.
  init<T: _Pointer>(_ ptr: T) {
    self.init(ptr._rawValue)
  }
}

extension UnsafeRawPointer {
  func offset(
    of offset: Int
  ) -> UnsafeRawPointer {
    advanced(by: MemoryLayout<Int>.size * offset)
  }
  
  func offset<T>(
    of offset: Int,
    as type: T.Type
  ) -> UnsafeRawPointer {
    advanced(by: MemoryLayout<T>.size * offset)
  }
  
  var mutable: UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(mutating: self)
  }
}

protocol LayoutWrapper {
  associatedtype Layout
  
  var ptr: UnsafeRawPointer { get }
}

extension LayoutWrapper {
  public var layout: Layout {
    ptr.load(as: Layout.self)
  }
}
