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
    of ptr: UnsafePointer<CChar>
  ) -> Any.Type? {
    return _getTypeByMangledNameInContext(
      UnsafePointer<UInt8>(ptr),
      UInt(getSymbolicMangledNameLength(ptr.raw)),
      genericContext: contextDescriptor.ptr,
      genericArguments: genericArgumentPtr
    )
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
  
  public var genericMetadata: [Metadata] {
    genericTypes.map { reflect($0) }
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
}
