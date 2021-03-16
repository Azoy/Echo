//
//  ExistentialMetatypeMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a metatype wrapping an existential
/// type.
///
/// ABI Stability: Unstable across all platforms
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | NA    | NA       | NA      | NA    | NA      |
///
public struct ExistentialMetatypeMetadata: Metadata, LayoutWrapper {
  typealias Layout = _ExistentialMetatypeMetadata
  
  /// Backing existential metatype metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The existential instance type that this metatype wraps.
  public var instanceType: Any.Type {
    layout._instanceType
  }
  
  /// The metadata for the existential instance type that this metatype wraps.
  public var instanceMetadata: ExistentialMetadata {
    reflect(instanceType) as! ExistentialMetadata
  }
  
  /// The flags specific to existential metadata.
  public var flags: ExistentialMetadata.Flags {
    layout._flags
  }
}

extension ExistentialMetatypeMetadata: Equatable {}

struct _ExistentialMetatypeMetadata {
  let _kind: Int
  let _instanceType: Any.Type
  let _flags: ExistentialMetadata.Flags
}
