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
  
  public var fieldOffsets: [Int] {
    var result = [Int]()
    
    for i in 0 ..< descriptor.numFields {
      let address = ptr.offset(of: descriptor.fieldOffsetVectorOffset)
                       .offset32(of: i)
      result.append(Int(address.load(as: UInt32.self)))
    }
    
    return result
  }
}

struct _StructMetadata {
  let _kind: Int
  let _descriptor: UnsafeRawPointer
}
