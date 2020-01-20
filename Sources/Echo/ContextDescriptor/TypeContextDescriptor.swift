//
//  TypeContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// A type context descriptor is a context descriptor who defines some new type.
/// This includes structs, classes, and enums. Protocols also define a new type,
/// but aren't considered type context descriptors.
public protocol TypeContextDescriptor: ContextDescriptor {
  /// The flags that describe this type context descriptor.
  var typeFlags: TypeContextDescriptorFlags { get }
  
  /// The name of this type.
  var name: String { get }
  
  /// The metadata access function pointer.
  var accessor: UnsafeRawPointer { get }
  
  /// The field descriptor that describes the stored representation of this
  /// type.
  var fields: FieldDescriptor { get }
}

extension TypeContextDescriptor {
  var _typeDescriptor: _TypeDescriptor {
    ptr.load(as: _TypeDescriptor.self)
  }
  
  /// The flags that describe this type context descriptor.
  public var typeFlags: TypeContextDescriptorFlags {
    TypeContextDescriptorFlags(bits: UInt64(flags.kindSpecificFlags))
  }
  
  /// The name of this type.
  public var name: String {
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = _typeDescriptor._name.address(from: offset)
    return address.string
  }
  
  /// The metadata access function pointer.
  public var accessor: UnsafeRawPointer {
    let offset = ptr.offset(of: 3, as: Int32.self)
    return _typeDescriptor._accessor.pointee(from: offset)!
  }
  
  /// Whether or not this type has a field descriptor.
  public var isReflectable: Bool {
    _typeDescriptor._fields.offset != 0
  }
  
  /// The field descriptor that describes the stored representation of this
  /// type.
  public var fields: FieldDescriptor {
    let offset = ptr.offset(of: 4, as: Int32.self)
    let address = _typeDescriptor._fields.address(from: offset).raw
    return FieldDescriptor(ptr: address)
  }
  
  /// The generic context that is unique to type context descriptors.
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
