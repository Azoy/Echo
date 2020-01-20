//
//  EnumMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents an `enum` type in Swift.
public struct EnumMetadata: TypeMetadata, LayoutWrapper {
  typealias Layout = _EnumMetadata
  
  /// Backing enum metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The enum context descriptor that describes this enum.
  public var descriptor: EnumDescriptor {
    layout._descriptor
  }
}

struct _EnumMetadata {
  let _kind: Int
  let _descriptor: EnumDescriptor
}
