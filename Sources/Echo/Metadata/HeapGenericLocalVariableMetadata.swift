//
//  HeapGenericLocalVariableMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents generic boxes that are instantiated
/// at runtime.
///
/// ABI Stability: Unstable across all platforms
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | NA    | NA       | NA      | NA    | NA      |
///
public struct HeapGenericLocalVariableMetadata: Metadata, LayoutWrapper {
  typealias Layout = _HeapGenericLocalVariableMetadata
  
  /// Backing heap generic local variable metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The offset from the box pointer to the value.
  public var offset: Int {
    Int(layout._offset)
  }
  
  /// The boxed type.
  public var boxedType: Any.Type {
    layout._boxedType
  }
  
  /// The metadata for the boxed type.
  public var boxedMetadata: Metadata {
    reflect(boxedType)
  }
}

extension HeapGenericLocalVariableMetadata: Equatable {}

struct _HeapGenericLocalVariableMetadata {
  let _kind: Int
  let _offset: UInt32
  let _boxedType: Any.Type
}
