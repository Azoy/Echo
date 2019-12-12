//
//  ClassDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ClassDescriptor: TypeContextDescriptor, LayoutWrapper {
  typealias Layout = _ClassDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var numFields: Int {
    Int(layout._numFields)
  }
  
  public var fieldOffsetVectorOffset: Int {
    Int(layout._fieldOffsetVectorOffset)
  }
}

struct _ClassDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _name: RelativeDirectPointer<CChar>
  let _accessor: RelativeDirectPointer<UnsafeRawPointer>
  let _fields: RelativeDirectPointer<_FieldDescriptor>
  let _superclass: RelativeDirectPointer<CChar>
  
  // This is either a uint32 for negative size, or a relative direct pointer
  // to class metadata bounds if the superclass is resilient.
  let _negativeSizeOrResilientBounds: UInt32
  
  // This is either a uint32 for positive size, or extra class flags
  // if the superclass is resilient.
  let _positiveSizeOrExtraFlags: UInt32
  
  let _numImmediateMembers: UInt32
  let _numFields: UInt32
  let _fieldOffsetVectorOffset: UInt32
}
