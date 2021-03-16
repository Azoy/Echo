//
//  OpaqueDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 - 2021 Alejandro Alonso. All rights reserved.
//

/// Represents a descriptor for an opaque type.
///
/// ABI Stability: Stable since the following
///
///     |    macOS    |  iOS/tvOS  |  watchOS  | Linux | Windows |
///     |-------------|------------|-----------|-------|---------|
///     | 10.15 <= .3 | 13.0 <= .3 | 6.0 <= .1 | NA    | NA      |
///
public struct OpaqueDescriptor: ContextDescriptor, LayoutWrapper {
  typealias Layout = _OpaqueDescriptor
  
  /// Backing OpaqueDescriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The number of underlying types for this opaque type.
  public var numUnderlyingTypes: Int {
    Int(layout._base._flags.kindSpecificFlags)
  }
  
  /// An array of mangled type names of the underlying types composing this
  /// opaque type.
  public var underlyingTypeMangledNames: [UnsafeRawPointer] {
    Array(unsafeUninitializedCapacity: numUnderlyingTypes) {
      var start = trailing
      
      if flags.isGeneric {
        start += genericContext!.size
      }
      
      for i in 0 ..< numUnderlyingTypes {
        let address = start.offset(of: i, as: RelativeDirectPointer<CChar>.self)
        $0[i] = address.relativeDirectAddress(as: CChar.self)
      }
      
      $1 = numUnderlyingTypes
    }
  }
}

extension OpaqueDescriptor: Equatable {}

struct _OpaqueDescriptor {
  let _base: _ContextDescriptor
}
