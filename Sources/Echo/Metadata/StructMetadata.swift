//
//  StructMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
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
}

struct _StructMetadata {
  let _kind: Int
  let _descriptor: UnsafeRawPointer
}
