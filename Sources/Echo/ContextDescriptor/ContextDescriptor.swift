//
//  Descriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
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
    let ptr = self.ptr.offset32(of: 1)
    
    guard let _parent = _base._parent.pointee(from: ptr) else {
      return nil
    }
    
    switch _parent._flags.kind {
    case .module:
      return ModuleDescriptor(ptr: _base._parent.address(from: ptr))
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
