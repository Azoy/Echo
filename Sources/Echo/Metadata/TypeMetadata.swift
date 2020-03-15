//
//  TypeMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// Type metadata refers to those metadata records who declare a new type in
/// Swift. Said metadata records only refer to structs, classes, and enums.
public protocol TypeMetadata: Metadata {}

extension TypeMetadata {
  /// Given a mangled type name to some field, superclass, etc., return the
  /// type. Using this is the preferred way to interact with mangled type names
  /// because this uses the metadata's generic context and arguments and such to
  /// fill in generic types along with caching the mangled name for future use.
  /// - Parameter mangledName: The mangled type name pointer to some type in
  ///                          this metadata's reach.
  /// - Returns: The type that the mangled type name refers to, if we're able
  ///            to demangle it.
  public func type(
    of mangledName: UnsafePointer<CChar>
  ) -> Any.Type? {
    let str = mangledName.string
    
    if mangledNameCache.keys.contains(ptr) {
      if mangledNameCache[ptr]!.keys.contains(str) {
        return mangledNameCache[ptr]![str]!
      }
    }
    
    let type = _getTypeByMangledNameInContext(
      UnsafePointer<UInt8>(mangledName),
      UInt(getSymbolicMangledNameLength(mangledName.raw)),
      genericContext: contextDescriptor.ptr,
      genericArguments: genericArgumentPtr
    )
    
    mangledNameCache[ptr, default: [:]][str] = type
    return type
  }
  
  /// The base type context descriptor for this type metadata record.
  public var contextDescriptor: TypeContextDescriptor {
    switch self {
    case let structMetadata as StructMetadata:
      return structMetadata.descriptor
    case let enumMetadata as EnumMetadata:
      return enumMetadata.descriptor
    case let classMetadata as ClassMetadata:
      return classMetadata.descriptor
    default:
      fatalError()
    }
  }
  
  public var fieldOffsets: [Int] {
    switch self {
    case is StructMetadata:
      return (self as! StructMetadata).fieldOffsets
    case is ClassMetadata:
      return (self as! ClassMetadata).fieldOffsets
    default:
      fatalError()
    }
  }
  
  var genericArgumentPtr: UnsafeRawPointer {
    switch self {
    case is StructMetadata:
      return ptr + MemoryLayout<_StructMetadata>.size
      
    case is EnumMetadata:
      return ptr + MemoryLayout<_EnumMetadata>.size
      
    case is ClassMetadata:
      let classMetadata = self as! ClassMetadata
      
      if !classMetadata.descriptor.typeFlags.classHasResilientSuperclass {
        if classMetadata.descriptor.typeFlags.classAreImmediateMembersNegative {
          return ptr.offset(of: -classMetadata.descriptor.negativeSize)
        } else {
          return ptr.offset(of: classMetadata.descriptor.positiveSize -
                                classMetadata.descriptor.numMembers)
        }
      }
      
      return ptr +
        classMetadata.descriptor.resilientBounds._immediateMembersOffset
      
    default:
      fatalError()
    }
  }
  
  /// An array of types that represent the generic arguments that make up this
  /// type.
  public var genericTypes: [Any.Type] {
    guard contextDescriptor.flags.isGeneric else {
      return []
    }
    
    let buffer = UnsafeBufferPointer<Any.Type>(
      start: UnsafePointer<Any.Type>(genericArgumentPtr),
      count: contextDescriptor.genericContext!.numParams
    )
    return Array(buffer)
  }
  
  /// An array of metadata records for the types that represent the generic
  /// arguments that make up this type.
  public var genericMetadata: [Metadata] {
    genericTypes.map { reflect($0) }
  }
}
