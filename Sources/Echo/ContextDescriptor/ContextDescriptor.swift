//
//  ContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public protocol ContextDescriptor {
  var ptr: UnsafeRawPointer { get }
  var flags: ContextDescriptorFlags { get }
  var parent: ContextDescriptor? { get }
}

extension ContextDescriptor {
  var _base: _Descriptor {
    ptr.load(as: _Descriptor.self)
  }
  
  public var flags: ContextDescriptorFlags {
    ptr.load(as: ContextDescriptorFlags.self)
  }
  
  public var parent: ContextDescriptor? {
    let offset = self.ptr.offset32(of: 1)
    
    guard let _parent = _base._parent.pointee(from: offset) else {
      return nil
    }
    
    let ptr = _base._parent.address(from: offset)
    
    switch _parent._flags.kind {
    case .module:
      return ModuleDescriptor(ptr: ptr)
    case .extension:
      return ExtensionDescriptor(ptr: ptr)
    case .anonymous:
      return AnonymousDescriptor(ptr: ptr)
    case .class:
      return ClassDescriptor(ptr: ptr)
    case .struct:
      return StructDescriptor(ptr: ptr)
    case .enum:
      return EnumDescriptor(ptr: ptr)
    default:
      return nil
    }
  }
}

// This is used as a base type that can be bit casted to.
struct _Descriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
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
  
  public let bits: UInt32
  
  public var isGeneric: Bool {
    bits & 0x80 == 0x80
  }
  
  public var isUnique: Bool {
    bits & 0x40 == 0x40
  }
  
  public var kind: ContextDescriptorKind {
    return ContextDescriptorKind(rawValue: Int(bits) & 0x1F)!
  }
  
  public var version: UInt8 {
    UInt8((bits >> 0x8) & 0xFF)
  }
  
  var kindSpecificFlags: UInt16 {
    UInt16((bits >> 0xF) & 0xFFFF)
  }
}