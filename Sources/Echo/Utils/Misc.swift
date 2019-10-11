//
//  Extensions.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
//

extension _Pointer {
  var raw: UnsafeRawPointer {
    UnsafeRawPointer(_rawValue)
  }
}

extension UnsafeRawPointer {
  func offset(
    of offset: Int
  ) -> UnsafeRawPointer {
    advanced(by: MemoryLayout<Int>.size * offset)
  }
  
  func offset32(
    of offset: Int
  ) -> UnsafeRawPointer {
    advanced(by: MemoryLayout<Int32>.size * offset)
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

public func type(
  of ptr: UnsafePointer<UInt8>,
  context: UnsafeRawPointer,
  genericArgs: UnsafeRawPointer
) -> Any.Type? {
  return _getTypeByMangledNameInContext(
    ptr,
    UInt(getSymbolicMangledNameLength(ptr.raw)),
    genericContext: context,
    genericArguments: genericArgs
  )
}
