//
//  TypeContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public protocol TypeContextDescriptor: ContextDescriptor {
  var typeFlags: TypeContextDescriptorFlags { get }
  var name: String { get }
  var accessor: UnsafeRawPointer { get }
  var fields: FieldDescriptor { get }
}

extension TypeContextDescriptor {
  var _typeDescriptor: _TypeDescriptor {
    ptr.load(as: _TypeDescriptor.self)
  }
  
  public var typeFlags: TypeContextDescriptorFlags {
    TypeContextDescriptorFlags(bits: UInt64(flags.kindSpecificFlags))
  }
  
  public var name: String {
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = _typeDescriptor._name.address(from: offset)
    return String(cString: address)
  }
  
  public var accessor: UnsafeRawPointer {
    let offset = ptr.offset(of: 3, as: Int32.self)
    return _typeDescriptor._accessor.pointee(from: offset)!
  }
  
  public var isReflectable: Bool {
    _typeDescriptor._fields.offset != 0
  }
  
  public var fields: FieldDescriptor {
    let offset = ptr.offset(of: 4, as: Int32.self)
    let address = _typeDescriptor._fields.address(from: offset).raw
    return FieldDescriptor(ptr: address)
  }
  
  public var typeGenericContext: TypeGenericContext {
    TypeGenericContext(ptr: ptr + genericContextOffset)
  }
}

struct _TypeDescriptor {
  let _base: _ContextDescriptor
  let _name: RelativeDirectPointer<CChar>
  let _accessor: RelativeDirectPointer<UnsafeRawPointer>
  let _fields: RelativeDirectPointer<_FieldDescriptor>
}
