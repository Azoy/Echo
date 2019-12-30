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

var mangledNameCache = [UnsafeRawPointer: [String: Any.Type?]]()

// https://github.com/apple/swift/blob/master/stdlib/public/core/KeyPath.swift
func getSymbolicMangledNameLength(_ base: UnsafeRawPointer) -> Int {
  var end = base
  while let current = Optional(end.load(as: UInt8.self)), current != 0 {
    // Skip the current character
    end = end + 1
    
    // Skip over a symbolic reference
    if current >= 0x1 && current <= 0x17 {
      end += 4
    } else if current >= 0x18 && current <= 0x1F {
      end += MemoryLayout<Int>.size
    }
  }
  
  return end - base
}
