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
  
  public var classType: Any.Type {
    layout._classMetadata
  }
  
  public var classMetadata: ClassMetadata {
    reflect(classType) as! ClassMetadata
  }
}

struct _ObjCClassWrapperMetadata {
  let _kind: Int
  let _classMetadata: Any.Type
}
