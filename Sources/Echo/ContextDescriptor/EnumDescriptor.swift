//
//  EnumDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public struct EnumDescriptor: TypeContextDescriptor {
  public let ptr: UnsafeRawPointer
  
  var _descriptor: _EnumDescriptor {
    ptr.load(as: _EnumDescriptor.self)
  }
  
  public var numPayloadCases: Int {
    Int(_descriptor._numPayloadCasesAndPayloadSizeOffset) & 0xFFFFFF
  }
  
  public var payloadSizeOffset: Int {
    (Int(_descriptor._numPayloadCasesAndPayloadSizeOffset) & 0xFF000000) >> 24
  }
  
  public var numEmptyCases: Int {
    Int(_descriptor._numEmptyCases)
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
