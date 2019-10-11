//
//  StructContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
//

public struct StructDescriptor: TypeContextDescriptor {
  public let ptr: UnsafeRawPointer
  
  var _descriptor: _StructDescriptor {
    ptr.load(as: _StructDescriptor.self)
  }
  
  public var numFields: Int {
    Int(_descriptor._numFields)
  }
  
  public var fieldOffsetVectorOffset: Int {
    Int(_descriptor._fieldOffsetVectorOffset)
  }
  
  public var genericContextHeader: TypeGenericContextDescriptorHeader? {
    guard flags.isGeneric else { return nil }
    
    let address = ptr.offset32(of: 7)
    return TypeGenericContextDescriptorHeader(ptr: address)
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
