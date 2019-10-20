//
//  MetatypeMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct MetatypeMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  var _metatype: _MetatypeMetadata {
    ptr.load(as: _MetatypeMetadata.self)
  }
  
  public var kind: MetadataKind {
    .metatype
  }
  
  public var instanceMetadata: Metadata {
    getMetadata(at: _metatype._instanceMetadata)
  }
  
  public var instanceType: Any.Type {
    unsafeBitCast(_metatype._instanceMetadata, to: Any.Type.self)
  }
}

struct _MetatypeMetadata {
  let _kind: Int
  let _instanceMetadata: UnsafeRawPointer
}
