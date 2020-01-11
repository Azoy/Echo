//
//  TypeMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public protocol TypeMetadata: Metadata {}

extension TypeMetadata {
  public func type(
    of mangledName: UnsafePointer<CChar>
  ) -> Any.Type? {
    let str = String(cString: mangledName)
    
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
  
  var genericArgumentPtr: UnsafeRawPointer {
    switch self {
    case is StructMetadata:
      return ptr + MemoryLayout<_StructMetadata>.size
    case is EnumMetadata:
      return ptr + MemoryLayout<_EnumMetadata>.size
    case is ClassMetadata:
      return ptr + MemoryLayout<_ClassMetadata>.size
    default:
      fatalError()
    }
  }
  
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
  
  public var genericMetadata: [Metadata] {
    genericTypes.map { reflect($0) }
  }
}
