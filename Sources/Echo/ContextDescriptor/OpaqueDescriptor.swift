//
//  OpaqueDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

/// Represents a descriptor for an opaque type.
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
  public var underlyingTypeMangledNames: [UnsafePointer<CChar>] {
    var result = [UnsafePointer<CChar>]()
    
    var start = trailing
    
    if flags.isGeneric {
      start += genericContext!.size
    }
    
    for i in 0 ..< numUnderlyingTypes {
      let address = start + i * MemoryLayout<RelativeDirectPointer<CChar>>.size
      result.append(address.relativeDirectAddress(as: CChar.self))
    }
    
    return result
  }
}

struct _OpaqueDescriptor {
  let _base: _ContextDescriptor
}
