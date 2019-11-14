//
//  StructMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct StructMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  var _struct: _StructMetadata {
    ptr.load(as: _StructMetadata.self)
  }
  
  public var kind: MetadataKind {
    .struct
  }
  
  public var descriptor: StructDescriptor {
    StructDescriptor(ptr: _struct._descriptor)
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
  
  public var fieldOffsets: [Int] {
    var result = [Int]()
    
    for i in 0 ..< descriptor.numFields {
      let address = ptr.offset(of: descriptor.fieldOffsetVectorOffset)
                       .offset(of: i, as: Int32.self)
      result.append(Int(address.load(as: UInt32.self)))
    }
    
    return result
  }
}

struct _StructMetadata {
  let _kind: Int
  let _descriptor: UnsafeRawPointer
}
