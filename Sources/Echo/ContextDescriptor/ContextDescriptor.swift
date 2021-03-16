//
//  ContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// A context descriptor describes any entity in Swift that contains other
/// types or contexts.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public protocol ContextDescriptor {
  /// Backing context descriptor pointer.
  var ptr: UnsafeRawPointer { get }
}

extension ContextDescriptor {
  var _descriptor: _ContextDescriptor {
    ptr.load(as: _ContextDescriptor.self)
  }
  
  /// The flags that describe this context including what kind it is,
  /// whether it's a generic context, and whether the context is unique along
  /// with other things.
  public var flags: ContextDescriptorFlags {
    _descriptor._flags
  }
  
  /// The parent context which this context descriptor resides in.
  public var parent: ContextDescriptor? {
    guard !_descriptor._parent.isNull else {
      return nil
    }
    
    let offset = ptr.offset(of: 1, as: Int32.self)
    
    return getContextDescriptor(
      at: _descriptor._parent.address(from: offset)
    )
  }
  
  var genericContextOffset: Int {
    switch self {
    case is AnonymousDescriptor:
      return MemoryLayout<_ContextDescriptor>.size
    case is ClassDescriptor:
      return MemoryLayout<_ClassDescriptor>.size
    case is EnumDescriptor:
      return MemoryLayout<_EnumDescriptor>.size
    case is ExtensionDescriptor:
      return MemoryLayout<_ExtensionDescriptor>.size
    case is OpaqueDescriptor:
      return MemoryLayout<_OpaqueDescriptor>.size
    case is StructDescriptor:
      return MemoryLayout<_StructDescriptor>.size
    default:
      fatalError()
    }
  }
  
  /// The generic information about a context including the number of generic
  /// parameters, number of requirements, the parameters themselves, the
  /// requirements themselves, and much more.
  public var genericContext: GenericContext? {
    guard flags.isGeneric else { return nil }
    
    if let type = self as? TypeContextDescriptor {
      return type.typeGenericContext.baseContext
    }
    
    return GenericContext(ptr: ptr + genericContextOffset)
  }
}

// This is used as a base type that can be bit casted to.
struct _ContextDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_ContextDescriptor>
}

func getContextDescriptor(
  at ptr: UnsafeRawPointer
) -> ContextDescriptor {
  #if _ptrauth(_arm64e)
  let ptr = __ptrauth_strip_asda(ptr)!
  #endif
  
  let flags = ptr.load(as: ContextDescriptorFlags.self)
  
  switch flags.kind {
  case .anonymous:
    return AnonymousDescriptor(ptr: ptr)
  case .class:
    return ClassDescriptor(ptr: ptr)
  case .enum:
    return EnumDescriptor(ptr: ptr)
  case .extension:
    return ExtensionDescriptor(ptr: ptr)
  case .module:
    return ModuleDescriptor(ptr: ptr)
  case .opaqueType:
    return OpaqueDescriptor(ptr: ptr)
  case .protocol:
    return ProtocolDescriptor(ptr: ptr)
  case .struct:
    return StructDescriptor(ptr: ptr)
  }
}
