//
//  Misc.swift
//  EchoTests
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

func typeArraysEquals(_ lhs: [Any.Type], _ rhs: [Any.Type]) -> Bool {
  assert(lhs.count == rhs.count)
  
  for i in 0 ..< lhs.count {
    if lhs[i] != rhs[i] {
      return false
    }
  }
  
  return true
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
