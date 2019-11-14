//
//  EnumMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct EnumMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  var _enum: _EnumMetadata {
    ptr.load(as: _EnumMetadata.self)
  }
  
  public var kind: MetadataKind {
    // This is either enum or optional
    MetadataKind(rawValue: _enum._kind)!
  }
  
  public var descriptor: EnumDescriptor {
    EnumDescriptor(ptr: _enum._descriptor)
  }
  
  var genericArgPtr: UnsafeRawPointer {
    precondition(descriptor.flags.isGeneric)
    return ptr.offset(of: 2)
  }
  
  public var genericMetadata: [Metadata] {
    var result = [Metadata]()
    
    for i in 0 ..< descriptor.genericContextHeader.numParams {
      let generic = genericArgPtr.offset(of: i).load(as: UnsafeRawPointer.self)
      result.append(getMetadata(at: generic))
    }
    
    return result
  }
  
  public var generics: [Any.Type] {
    genericMetadata.map { $0.type }
  }
}

struct _EnumMetadata {
  let _kind: Int
  let _descriptor: UnsafeRawPointer
}
