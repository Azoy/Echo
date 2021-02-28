//
//  Misc.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

import Foundation

extension UnsafePointer {
  var raw: UnsafeRawPointer {
    UnsafeRawPointer(self)
  }
}

extension UnsafeMutablePointer {
  var raw: UnsafeRawPointer {
    UnsafeRawPointer(self)
  }
}

extension UnsafeMutableRawPointer {
  var raw: UnsafeRawPointer {
    UnsafeRawPointer(self)
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

extension UnsafePointer where Pointee == CChar {
  var string: String {
    String(cString: self)
  }
}

extension UnsafeRawPointer {
  var string: String {
    String(cString: assumingMemoryBound(to: CChar.self))
  }
}

extension NSLock {
  func withLock<T>(_ closure: () throws -> T) rethrows -> T {
    lock()
    defer { unlock() }
    return try closure()
  }
}

protocol LayoutWrapper {
  associatedtype Layout
  
  var ptr: UnsafeRawPointer { get }
}

extension LayoutWrapper {
  var layout: Layout {
    ptr.load(as: Layout.self)
  }
  
  var trailing: UnsafeRawPointer {
    ptr + MemoryLayout<Layout>.size
  }
  
  func address<T>(
    for field: KeyPath<Layout, T>
  ) -> UnsafeRawPointer {
    let offset = MemoryLayout<Layout>.offset(of: field)!
    return ptr + offset
  }
  
  func address<T: RelativePointer>(
    for field: KeyPath<Layout, T>
  ) -> UnsafeRawPointer {
    let offset = MemoryLayout<Layout>.offset(of: field)!
    return layout[keyPath: field].address(from: ptr + offset)
  }
}

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
