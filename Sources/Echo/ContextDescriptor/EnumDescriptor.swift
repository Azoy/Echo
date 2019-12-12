//
//  EnumDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct EnumDescriptor: TypeContextDescriptor, LayoutWrapper {
  typealias Layout = _EnumDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var numPayloadCases: Int {
    Int(layout._numPayloadCasesAndPayloadSizeOffset) & 0xFFFFFF
  }
  
  public var payloadSizeOffset: Int {
    (Int(layout._numPayloadCasesAndPayloadSizeOffset) & 0xFF000000) >> 24
  }
  
  public var numEmptyCases: Int {
    Int(layout._numEmptyCases)
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
