//
//  EnumMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents an `enum` type in Swift.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct EnumMetadata: TypeMetadata, LayoutWrapper {
  typealias Layout = _EnumMetadata
  
  /// Backing enum metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The enum context descriptor that describes this enum.
  public var descriptor: EnumDescriptor {
    EnumDescriptor(ptr: layout._descriptor.signed)
  }
}

extension EnumMetadata: Equatable {}

struct _EnumMetadata {
  let _kind: Int
  let _descriptor: SignedPointer<EnumDescriptor>
}
