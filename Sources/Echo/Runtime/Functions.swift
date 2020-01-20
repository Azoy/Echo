//
//  Functions.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

import CEcho

//===----------------------------------------------------------------------===//
// Box Functions
//===----------------------------------------------------------------------===//

/// A box pair is the pair of heap object + value within said heap object.
/// When you allocate a new box, you're given a pointer to the heap object
/// along with a pointer to the value inside the heap object.
public struct BoxPair {
  /// A pointer to the allocated heap object.
  public let heapObj: UnsafePointer<HeapObject>
  
  /// A pointer to the value inside the heap object.
  public let buffer: UnsafeRawPointer
}

@_silgen_name("swift_allocBox")
public func swift_allocBox(for type: Any.Type) -> BoxPair

public func swift_allocBox(for metadata: Metadata) -> BoxPair {
  swift_allocBox(for: metadata.type)
}

@_silgen_name("swift_makeBoxUnique")
func _swift_makeBoxUnique(
  for buffer: UnsafeRawPointer,
  type: Any.Type,
  alignMask: UInt
) -> BoxPair

public func swift_projectBox(
  for heapObj: UnsafePointer<HeapObject>
) -> UnsafeRawPointer {
  swift_projectBox(heapObj.raw.mutable)!.raw
}

public func swift_release(_ heapObj: UnsafePointer<HeapObject>) {
  swift_release(heapObj.raw.mutable)
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
  for type: Any.Type,
  qualified: Bool
) -> String {
  String(
    cString: _swift_getTypeName(
      for: unsafeBitCast(type, to: UnsafeRawPointer.self),
      qualified: qualified
    ).data
  )
}

public func swift_getTypeName(
  for metadata: Metadata,
  qualified: Bool
) -> String {
  swift_getTypeName(for: metadata.type, qualified: qualified)
}
