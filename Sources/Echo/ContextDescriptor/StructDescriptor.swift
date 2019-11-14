//
//  StructDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct StructDescriptor: TypeContextDescriptor {
  public let ptr: UnsafeRawPointer
  
  var _struct: _StructDescriptor {
    ptr.load(as: _StructDescriptor.self)
  }
  
  public var numFields: Int {
    Int(_struct._numFields)
  }
  
  public var fieldOffsetVectorOffset: Int {
    Int(_struct._fieldOffsetVectorOffset)
  }
  
  public var genericContextHeader: TypeGenericContextDescriptorHeader {
    return TypeGenericContextDescriptorHeader(
      ptr: ptr.offset(of: 7, as: Int32.self)
    )
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
