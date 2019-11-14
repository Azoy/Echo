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
    let address = _typeDescriptor._name.address(
      from: ptr.offset(of: 2, as: Int32.self)
    )
    return String(cString: UnsafePointer<CChar>(address))
  }
  
  public var accessor: UnsafeRawPointer {
    _typeDescriptor._accessor.pointee(from: ptr.offset(of: 3, as: Int32.self))!
  }
  
  public var isReflectable: Bool {
    _typeDescriptor._fields.offset != 0
  }
  
  public var fields: FieldDescriptor {
    let address = _typeDescriptor._fields.address(
      from: ptr.offset(of: 4, as: Int32.self)
    )
    return FieldDescriptor(ptr: address)
  }
  
  public var genericContext: UnsafeRawPointer {
    switch flags.kind {
    case .struct:
      return StructDescriptor(ptr: ptr).genericContext
    default:
      // FIXME: Add more generic contexts...
      fatalError("This shouldn't happen...")
    }
  }
}

public struct TypeContextDescriptorFlags {
  
  public let bits: UInt64
  
  public var metadataInitKind: MetadataInitializationKind {
    MetadataInitializationKind(rawValue: UInt16(bits) & 0x3)!
  }
  
  public var hasImportInfo: Bool {
    bits & 0x4 != 0
  }
  
  public var resilientSuperclassRefKind: TypeReferenceKind {
    TypeReferenceKind(rawValue: UInt16(bits) & 0xE00)!
  }
  
  public var classAreImmediateMembersNegative: Bool {
    bits & 0x1000 != 0
  }
  
  public var classHasResilientSuperclass: Bool {
    bits & 0x2000 != 0
  }
  
  public var classHasOverrideTable: Bool {
    bits & 0x4000 != 0
  }
  
  public var classHasVTable: Bool {
    bits & 0x8000 != 0
  }
}

public enum MetadataInitializationKind: UInt16 {
  case none = 0
  case singleton = 1
  case foreign = 2
}

public enum TypeReferenceKind: UInt16 {
  case directTypeDescriptor = 0x0
  case indirectTypeDescriptor = 0x1
  case directObjCClass = 0x2
  case indirectObjCClass = 0x3
}

struct _TypeDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _name: RelativeDirectPointer<CChar>
  let _accessor: RelativeDirectPointer<UnsafeRawPointer>
  let _fields: RelativeDirectPointer<_FieldDescriptor>
}
