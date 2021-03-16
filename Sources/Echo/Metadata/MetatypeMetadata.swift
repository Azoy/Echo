//
//  MetatypeMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a metatype wrapping some instance
/// type.
///
/// ABI Stability: Unstable across all platforms
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | NA    | NA       | NA      | NA    | NA      |
///
public struct MetatypeMetadata: Metadata, LayoutWrapper {
  typealias Layout = _MetatypeMetadata
  
  /// Backing metatype metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The instance type that this metatype wraps.
  public var instanceType: Any.Type {
    layout._instanceType
  }
  
  /// The metadata for the instance type this metatype wraps.
  public var instanceMetadata: Metadata {
    reflect(instanceType)
  }
}

extension MetatypeMetadata: Equatable {}

struct _MetatypeMetadata {
  let _kind: Int
  let _instanceType: Any.Type
}
