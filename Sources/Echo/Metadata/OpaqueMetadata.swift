//
//  OpaqueMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents some opaque type in Swift. An opaque
/// type might include a private structure, or perhaps some metadata for the
/// various Builtin types in Swift.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct OpaqueMetadata: Metadata {
  /// Backing opaque metadata pointer.
  public let ptr: UnsafeRawPointer
}

extension OpaqueMetadata: Equatable {}
