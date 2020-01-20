//
//  OpaqueMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents some opaque type in Swift. An opaque
/// type might include a private structure, or perhaps some metadata for the
/// various Builtin types in Swift.
public struct OpaqueMetadata: Metadata {
  /// Backing opaque metadata pointer.
  public let ptr: UnsafeRawPointer
}
