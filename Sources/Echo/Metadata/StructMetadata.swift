//
//  StructMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a `struct` type in Swift.
public struct StructMetadata: TypeMetadata, LayoutWrapper {
  typealias Layout = _StructMetadata
  
  /// Backing struct metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The struct context descriptor that describes this struct.
  public var descriptor: StructDescriptor {
    layout._descriptor
  }
  
  /// An array of field offsets for this struct's stored representation.
  public var fieldOffsets: [Int] {
    let start = ptr.offset(of: descriptor.fieldOffsetVectorOffset)
    let buffer = UnsafeBufferPointer<UInt32>(
      start: UnsafePointer<UInt32>(start),
      count: descriptor.numFields
    )
    return Array(buffer).map { Int($0) }
  }
}

struct _StructMetadata {
  let _kind: Int
  let _descriptor: StructDescriptor
}
