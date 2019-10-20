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
func _allocBox(for metadata: UnsafeRawPointer) -> BoxPair

public func allocBox(for metadata: Metadata) -> BoxPair {
  _allocBox(for: metadata.ptr)
}

public func release(_ heapObj: UnsafePointer<HeapObject>) {
  swift_release(heapObj.raw.mutable)
}

public func projectBox(
  for heapObj: UnsafePointer<HeapObject>
) -> UnsafeRawPointer {
  swift_projectBox(heapObj.raw.mutable)!.raw
}

struct TypeNamePair {
  public let data: UnsafePointer<CChar>
  public let length: UInt
}

@_silgen_name("swift_getTypeName")
func _getTypeName(
  for metadata: UnsafeRawPointer,
  qualified: Bool
) -> TypeNamePair

public func getTypeName(
  for metadata: Metadata,
  qualified: Bool
) -> String {
  String(cString: _getTypeName(for: metadata.ptr, qualified: qualified).data)
}
