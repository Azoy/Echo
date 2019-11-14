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

public func getTypeName(
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
