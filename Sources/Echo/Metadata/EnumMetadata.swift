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
}

struct _EnumMetadata {
  let _kind: Int
  let _descriptor: UnsafeRawPointer
}
