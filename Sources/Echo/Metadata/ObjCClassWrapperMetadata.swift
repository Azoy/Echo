//
//  ObjCClassWrapperMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ObjCClassWrapperMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  var _wrapper: _ObjCClassWrapperMetadata {
    ptr.load(as: _ObjCClassWrapperMetadata.self)
  }
  
  public var kind: MetadataKind {
    .objcClassWrapper
  }
  
  public var classMetadata: ClassMetadata {
    ClassMetadata(ptr: _wrapper._classMetadata)
  }
  
  public var classType: Any.Type {
    classMetadata.type
  }
}

struct _ObjCClassWrapperMetadata {
  let _kind: Int
  let _classMetadata: UnsafeRawPointer
}
