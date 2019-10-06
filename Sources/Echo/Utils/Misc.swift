//
//  Extensions.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
//

extension UnsafeRawPointer {
  func offset<T: BinaryInteger>(
    of offset: Int,
    as type: T.Type
  ) -> UnsafeRawPointer {
    advanced(by: MemoryLayout<T>.size * offset)
  }
}

func getSymbolicNameLength(_ base: UnsafeRawPointer) -> UInt {
  var end = UnsafePointer<Int8>(base._rawValue)
  while end.pointee != 0 {
    if end.pointee >= 0x1 && end.pointee <= 0x17 {
      end += MemoryLayout<Int32>.size
    } else if end.pointee >= 0x18 && end.pointee <= 0x1F {
      end += MemoryLayout<Int>.size
    }
    
    end += 1
  }
  
  return UInt(bitPattern: end) - UInt(bitPattern: base)
}
