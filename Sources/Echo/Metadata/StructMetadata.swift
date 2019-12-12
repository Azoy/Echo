//
//  StructMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct StructMetadata: TypeMetadata, LayoutWrapper {
  typealias Layout = _StructMetadata
  
  public let ptr: UnsafeRawPointer
  
  public var descriptor: StructDescriptor {
    layout._descriptor
  }
  
  public var fieldOffsets: [Int] {
    let start = ptr.offset(of: descriptor.fieldOffsetVectorOffset)
    let buffer = UnsafeBufferPointer<UInt32>(
      start: UnsafePointer<UInt32>(start),
      count: descriptor.numFields
    )
    return Array(buffer).map { Int($0) }
  }
}

struct _StructMetadata {
  let _kind: Int
  let _descriptor: StructDescriptor
}
