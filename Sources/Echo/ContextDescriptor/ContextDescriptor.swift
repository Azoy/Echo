//
//  Descriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
//

public protocol ContextDescriptor {
  var ptr: UnsafeRawPointer { get }
  var flags: ContextDescriptorFlags { get }
  var parentContextDescriptor: ContextDescriptor? { get }
  
  init(ptr: UnsafeRawPointer)
}

extension ContextDescriptor {
  public var flags: ContextDescriptorFlags {
    ptr.load(as: ContextDescriptorFlags.self)
  }
  
  public var parentContextDescriptor: ContextDescriptor? {
    let address = ptr.offset(of: 1, as: Int32.self)
    let relativePtr = RelativeIndirectablePointer<_BaseDescriptor>(
      ptr: address,
      offset: address.load(as: Int32.self),
      nullable: true
    )
    
    return getParentDescriptor(relativePtr)
  }
}

// This is used as a base type that can be bit casted to.
struct _BaseDescriptor {
  let flags: ContextDescriptorFlags
  let parent: Int32 // This is an offset for a relative pointer
}

public enum ContextDescriptorKind: Int {
  case module = 0
  case `extension` = 1
  case anonymous = 2
  case `protocol` = 3
  case opaqueType = 4
  case `class` = 16
  case `struct` = 17
  case `enum` = 18
}

public struct ContextDescriptorFlags {
  
  let value: UInt32
  
  public var isGeneric: Bool {
    value & 0x80 != 0
  }
  
  public var isUnique: Bool {
    value & 0x40 != 0
  }
  
  public var kind: ContextDescriptorKind {
    return ContextDescriptorKind(rawValue: Int(value) & 0x1F)!
  }
  
  public var version: UInt8 {
    UInt8((value >> 0x8) & 0xFF)
  }
  
  var kindSpecificFlags: UInt16 {
    UInt16((value >> 0xF) & 0xFFFF)
  }
  
}

func getParentDescriptor<T: RelativePointer>(
  _ _parentDescriptor: T
) -> ContextDescriptor? where T.Pointee == _BaseDescriptor {
  guard let base = _parentDescriptor.pointee else {
    return nil
  }
  
  switch base.flags.kind {
  case .module:
    return ModuleDescriptor(ptr: _parentDescriptor.address)
  case .struct:
    return StructDescriptor(ptr: _parentDescriptor.address)
  default:
    return nil
  }
}
