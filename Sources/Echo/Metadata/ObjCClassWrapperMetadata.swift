//
//  ObjCClassWrapperMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ObjCClassWrapperMetadata: Metadata, LayoutWrapper {
  typealias Layout = _ObjCClassWrapperMetadata
  
  public let ptr: UnsafeRawPointer
  
  public var classMetadata: ClassMetadata {
    ClassMetadata(ptr: unsafeBitCast(classType, to: UnsafeRawPointer.self))
  }
  
  public var classType: Any.Type {
    layout._classMetadata
  }
}

struct _ObjCClassWrapperMetadata {
  let _kind: Int
  let _classMetadata: Any.Type
}
