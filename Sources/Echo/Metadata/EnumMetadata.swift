//
//  EnumMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct EnumMetadata: TypeMetadata, LayoutWrapper {
  typealias Layout = _EnumMetadata
  
  public let ptr: UnsafeRawPointer
  
  public var descriptor: EnumDescriptor {
    layout._descriptor
  }
}

struct _EnumMetadata {
  let _kind: Int
  let _descriptor: EnumDescriptor
}
