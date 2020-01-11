//
//  Functions.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import CEcho

//===----------------------------------------------------------------------===//
// Box Functions
//===----------------------------------------------------------------------===//

public struct BoxPair {
  public let heapObj: UnsafePointer<HeapObject>
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

@_silgen_name("swift_checkMetadataState")
public func swift_checkMetadataState(
  _ request: MetadataRequest,
  for type: Any.Type
) -> MetadataResponse

public func swift_checkMetadataState(
  _ request: MetadataRequest,
  for metadata: Metadata
) -> MetadataResponse {
  swift_checkMetadataState(request, for: metadata.type)
}

@_silgen_name("swift_getTupleTypeMetadata2")
func _swift_getTupleTypeMetadata2(
  _ request: MetadataRequest,
  type1: Any.Type,
  type2: Any.Type,
  labels: UnsafePointer<CChar>
  // There's another proposed witnesses field here, but it's best to just leave
  // that blank.
) -> MetadataResponse

public func swift_getTupleTypeMetadata2(
  _ request: MetadataRequest,
  type1: Any.Type,
  type2: Any.Type,
  labels: String
) -> MetadataResponse {
  labels.withCString {
    _swift_getTupleTypeMetadata2(
      request,
      type1: type1,
      type2: type2,
      labels: $0
    )
  }
}

public func swift_getTupleTypeMetadata2(
  _ request: MetadataRequest,
  type1: Metadata,
  type2: Metadata,
  labels: String
) -> MetadataResponse {
  swift_getTupleTypeMetadata2(
    request,
    type1: type1.type,
    type2: type2.type,
    labels: labels
  )
}
