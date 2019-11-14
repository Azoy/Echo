//
//  EnumDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct EnumDescriptor: TypeContextDescriptor {
  public let ptr: UnsafeRawPointer
  
  var _enum: _EnumDescriptor {
    ptr.load(as: _EnumDescriptor.self)
  }
  
  public var numPayloadCases: Int {
    Int(_enum._numPayloadCasesAndPayloadSizeOffset) & 0xFFFFFF
  }
  
  public var payloadSizeOffset: Int {
    (Int(_enum._numPayloadCasesAndPayloadSizeOffset) & 0xFF000000) >> 24
  }
  
  public var numEmptyCases: Int {
    Int(_enum._numEmptyCases)
  }
  
  public var genericContextHeader: TypeGenericContextDescriptorHeader {
    return TypeGenericContextDescriptorHeader(
      ptr: ptr.offset(of: 7, as: Int32.self)
    )
  }
}

struct _EnumDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _name: RelativeDirectPointer<CChar>
  let _accessor: RelativeDirectPointer<UnsafeRawPointer>
  let _fields: RelativeDirectPointer<_FieldDescriptor>
  let _numPayloadCasesAndPayloadSizeOffset: UInt32
  let _numEmptyCases: UInt32
}
