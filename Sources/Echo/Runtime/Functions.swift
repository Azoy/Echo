//
//  Functions.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import CEcho

public struct BoxPair {
  public let heapObj: UnsafePointer<HeapObject>
  public let buffer: UnsafeRawPointer
}

@_silgen_name("swift_allocBox")
func _swift_allocBox(for metadata: UnsafeRawPointer) -> BoxPair

public func swift_allocBox(for metadata: Metadata) -> BoxPair {
  _swift_allocBox(for: metadata.ptr)
}

public func swift_release(_ heapObj: UnsafePointer<HeapObject>) {
  swift_release(heapObj.raw.mutable)
}

public func swift_projectBox(
  for heapObj: UnsafePointer<HeapObject>
) -> UnsafeRawPointer {
  swift_projectBox(heapObj.raw.mutable)!.raw
}

struct TypeNamePair {
  public let data: UnsafePointer<CChar>
  public let length: UInt
}

@_silgen_name("swift_getTypeName")
func _swift_getTypeName(
  for metadata: UnsafeRawPointer,
  qualified: Bool
) -> TypeNamePair

public func swift_getTypeName(
  for metadata: Metadata,
  qualified: Bool
) -> String {
  String(
    cString: _swift_getTypeName(
      for: metadata.ptr,
      qualified: qualified
    ).data
  )
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
