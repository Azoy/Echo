//
//  Functions.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
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

/*
public func swift_projectBox(
  for heapObj: UnsafePointer<HeapObject>
) -> UnsafeRawPointer {
  swift_projectBox(heapObj.raw.mutable)!.raw
}
 */

//===----------------------------------------------------------------------===//
// HeapObject Functions
//===----------------------------------------------------------------------===//

/*
public func swift_allocObject(
  for type: ClassMetadata,
  size: Int,
  alignmentMask: Int
) -> UnsafeRawPointer? {
  if let object = swift_allocObject(type.ptr.mutable, size, alignmentMask) {
    return object.raw
  }
  
  return nil
}

public func swift_release(_ heapObj: UnsafePointer<HeapObject>) {
  swift_release(heapObj.raw.mutable)
}
 */

//===----------------------------------------------------------------------===//
// Mangling Functions
//===----------------------------------------------------------------------===//

struct TypeNamePair {
  public let data: UnsafePointer<CChar>
  public let length: UInt
}

@_silgen_name("swift_getTypeName")
func _swift_getTypeName(
  for metadata: UnsafeRawPointer,
  qualified: Bool
) -> TypeNamePair

/// Gets the types name, either qualified (full name representation), or non
/// qualified (just the type name).
/// - Parameter type: Type to get the name of.
/// - Parameter qualified: Whether or not this name should be qualified.
/// - Returns: A string who contains the name of the type.
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

/// Gets the types name, either qualified (full name representation), or non
/// qualified (just the type name).
/// - Parameter metadata: Type metadata to get the name of.
/// - Parameter qualified: Whether or not this name should be qualified.
/// - Returns: A string who contains the name of the type metadata.
public func swift_getTypeName(
  for metadata: Metadata,
  qualified: Bool
) -> String {
  swift_getTypeName(for: metadata.type, qualified: qualified)
}

//===----------------------------------------------------------------------===//
// Protocol Functions
//===----------------------------------------------------------------------===//

/// Checks whether the type conforms to the given protocol.
/// - Parameter type: Type to check conformance of.
/// - Parameter protocol: The protocol to check to see if the type conforms to.
/// - Returns: A witness table of the conformance if it does conform, or nil if
///            it doesn't conform.
public func swift_conformsToProtocol(
  type: Any.Type,
  protocol: ProtocolDescriptor
) -> WitnessTable? {
  let wtPtr = swift_conformsToProtocol(
    unsafeBitCast(type, to: UnsafeRawPointer.self),
    `protocol`.ptr
  )
  
  guard wtPtr != nil else {
    return nil
  }
  
  return WitnessTable(ptr: wtPtr!)
}

/// Checks whether the type conforms to the given protocol.
/// - Parameter metadata: Type metadata to check conformance of.
/// - Parameter protocol: The protocol to check to see if the type conforms to.
/// - Returns: A witness table of the conformance if it does conform, or nil if
///            it doesn't conform.
public func swift_conformsToProtocol(
  metadata: Metadata,
  protocol: ProtocolDescriptor
) -> WitnessTable? {
  swift_conformsToProtocol(type: metadata.type, protocol: `protocol`)
}
