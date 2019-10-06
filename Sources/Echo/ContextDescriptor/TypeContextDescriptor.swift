//
//  TypeContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public protocol TypeContextDescriptor: ContextDescriptor {
  var typeFlags: TypeContextDescriptorFlags { get }
  var name: String { get }
  var accessorFunc: Int32 { get }
  var fieldDescriptor: FieldDescriptor { get }
  var numFields: Int32 { get }
  var fieldOffset: Int32 { get }
}

extension TypeContextDescriptor {
  public var typeFlags: TypeContextDescriptorFlags {
    TypeContextDescriptorFlags(bits: flags.kindSpecificFlags)
  }
  
  public var name: String {
    let address = ptr.offset(of: 2, as: Int32.self)
    let relativePtr = RelativeDirectPointer<CChar>(
      ptr: address,
      offset: address.load(as: Int32.self)
    )
    
    return String(cString: UnsafePointer<CChar>(relativePtr.address._rawValue))
  }
  
  public var accessorFunc: Int32 {
    let address = ptr.offset(of: 3, as: Int32.self)
    return address.load(as: Int32.self)
  }
  
  public var fieldDescriptor: FieldDescriptor {
    let address = ptr.offset(of: 4, as: Int32.self)
    let relativePtr = RelativeDirectPointer<FieldDescriptor>(
      ptr: address,
      offset: address.load(as: Int32.self),
      nullable: true
    )
    
    return FieldDescriptor(ptr: relativePtr.address)
  }
  
  public var numFields: Int32 {
    let address = ptr.offset(of: 5, as: Int32.self)
    return address.load(as: Int32.self)
  }
  
  public var fieldOffset: Int32 {
    let address = ptr.offset(of: 6, as: Int32.self)
    return address.load(as: Int32.self)
  }
}

public struct TypeContextDescriptorFlags: FlagSet {
  
  let bits: UInt16
  
  public var classAreImmediateMembersNegative: Bool {
    getFlag(at: 12)
  }
  
  public var classHasOverrideTable: Bool {
    getFlag(at: 14)
  }
  
  public var classHasResilientSuperclass: Bool {
    getFlag(at: 13)
  }
  
  public var classHasVTable: Bool {
    getFlag(at: 15)
  }
  
  public var hasImportInfo: Bool {
    getFlag(at: 2)
  }
  
  public var metadataInitKind: MetadataInitializationKind {
    MetadataInitializationKind(rawValue: getField(at: 0, bitWidth: 2))!
  }
  
  public var resilientSuperclassRefKind: TypeReferenceKind {
    TypeReferenceKind(rawValue: getField(at: 9, bitWidth: 3))!
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
