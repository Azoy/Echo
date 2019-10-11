//
//  TypeContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public protocol TypeContextDescriptor: ContextDescriptor {
  var typeFlags: TypeContextDescriptorFlags { get }
  var name: String { get }
  var accessor: Int32 { get }
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
    let address = _typeDescriptor._name.address(from: ptr.offset32(of: 2))
    return String(cString: UnsafePointer<CChar>(address._rawValue))
  }
  
  public var accessor: Int32 {
    _typeDescriptor._accessor
  }
  
  public var fields: FieldDescriptor {
    let address = _typeDescriptor._fields.address(from: ptr.offset32(of: 4))
    return FieldDescriptor(ptr: address)
  }
}

struct _TypeDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _name: RelativeDirectPointer<CChar>
  let _accessor: Int32
  let _fields: RelativeDirectPointer<_FieldDescriptor>
}

public struct TypeContextDescriptorFlags {
  
  let bits: UInt64
  
  public var metadataInitKind: MetadataInitializationKind {
    MetadataInitializationKind(rawValue: UInt16(bits) & 0x3)!
  }
  
  public var hasImportInfo: Bool {
    bits & 0x4 == 1
  }
  
  public var resilientSuperclassRefKind: TypeReferenceKind {
    TypeReferenceKind(rawValue: UInt16(bits) & 0xE00)!
  }
  
  public var classAreImmediateMembersNegative: Bool {
    bits & 0x1000 == 1
  }
  
  public var classHasResilientSuperclass: Bool {
    bits & 0x2000 == 1
  }
  
  public var classHasOverrideTable: Bool {
    bits & 0x4000 == 1
  }
  
  public var classHasVTable: Bool {
    bits & 0x8000 == 1
  }
}

extension TypeContextDescriptorFlags {
  public enum MetadataInitializationKind: UInt16 {
    case none = 0
    case singleton = 1
    case foreign = 2
  }
}

public enum TypeReferenceKind: UInt16 {
  case directTypeDescriptor = 0x0
  case indirectTypeDescriptor = 0x1
  case directObjCClass = 0x2
  case indirectObjCClass = 0x3
}
