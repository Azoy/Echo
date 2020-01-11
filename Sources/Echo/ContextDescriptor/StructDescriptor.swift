//
//  StructDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct StructDescriptor: TypeContextDescriptor, LayoutWrapper {
  typealias Layout = _StructDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var numFields: Int {
    Int(layout._numFields)
  }
  
  public var fieldOffsetVectorOffset: Int {
    Int(layout._fieldOffsetVectorOffset)
  }
}

struct _StructDescriptor {
  let _base: _TypeDescriptor
  let _numFields: UInt32
  let _fieldOffsetVectorOffset: UInt32
}
