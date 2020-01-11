//
//  MetatypeMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct MetatypeMetadata: Metadata, LayoutWrapper {
  typealias Layout = _MetatypeMetadata
  
  public let ptr: UnsafeRawPointer
  
  public var instanceType: Any.Type {
    layout._instanceMetadata
  }
  
  public var instanceMetadata: Metadata {
    reflect(instanceType)
  }
}

struct _MetatypeMetadata {
  let _kind: Int
  let _instanceMetadata: Any.Type
}
