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
}

struct _StructMetadata {
  let _kind: Int
  let _descriptor: StructDescriptor
}
