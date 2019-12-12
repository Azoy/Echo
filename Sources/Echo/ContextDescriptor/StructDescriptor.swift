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
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _name: RelativeDirectPointer<CChar>
  let _accessor: RelativeDirectPointer<UnsafeRawPointer>
  let _fields: RelativeDirectPointer<_FieldDescriptor>
  let _numFields: UInt32
  let _fieldOffsetVectorOffset: UInt32
}
