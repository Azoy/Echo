//
//  ProtocolDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ProtocolDescriptor: ContextDescriptor, LayoutWrapper {
  typealias Layout = _ProtocolDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var protocolFlags: Flags {
    Flags(bits: flags.kindSpecificFlags)
  }
  
  public var name: String {
    let address = layout._name.address(from: ptr.offset(of: 2, as: Int32.self))
    return String(cString: UnsafePointer<CChar>(address))
  }
  
  public var numRequirementsInSignature: Int {
    Int(layout._numRequirementsInSignature)
  }
  
  public var numRequirements: Int {
    Int(layout._numRequirements)
  }
  
  public var associatedTypeNames: String {
    let address = layout._associatedTypeNames.address(
      from: ptr.offset(of: 5, as: Int32.self)
    )
    return String(cString: UnsafePointer<CChar>(address))
  }
}

extension ProtocolDescriptor {
  public struct Flags {
    public let bits: UInt16
    
    public var hasClassConstraint: Bool {
      bits & 0x1 != 0
    }
    
    public var isResilient: Bool {
      bits & 0x2 != 0
    }
    
    public var specialProtocol: SpecialProtocol {
      SpecialProtocol(rawValue: UInt8(bits & 0xFC))!
    }
  }
}

public struct GenericRequirementDescriptor: LayoutWrapper {
  typealias Layout = _GenericRequirementDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var flags: Flags {
    layout._flags
  }
  
  public var paramMangledName: UnsafePointer<CChar> {
    let offset = ptr.offset(of: 1, as: Int32.self)
    let address = layout._param.address(from: offset)
    return UnsafePointer<CChar>(address)
  }
  
  public var mangledTypeName: UnsafePointer<CChar> {
    assert(flags.kind == .sameType || flags.kind == .baseClass)
    let relativePointer = RelativeDirectPointer<CChar>(
      offset: layout._requirement
    )
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = relativePointer.address(from: offset)
    return UnsafePointer<CChar>(address)
  }
  
  public var `protocol`: ProtocolDescriptor {
    assert(flags.kind == .protocol)
    let relativePointer =
      RelativeIndirectablePointerIntPair<_ProtocolDescriptor, UInt8>(
        offset: layout._requirement
      )
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = relativePointer.address(from: offset)
    return ProtocolDescriptor(ptr: address)
  }
  
  
  
  public var layoutKind: GenericRequirementLayoutKind {
    assert(flags.kind == .layout)
    return GenericRequirementLayoutKind(rawValue: UInt32(layout._requirement))!
  }
}

extension GenericRequirementDescriptor {
  public struct Flags {
    public let bits: UInt32
    
    public var kind: GenericRequirementKind {
      GenericRequirementKind(rawValue: UInt8(bits & 0x1F))!
    }
    
    public var hasExtraArgument: Bool {
      bits & 0x40 != 0
    }
    
    public var hasKeyArgument: Bool {
      bits & 0x80 != 0
    }
  }
}

public enum GenericRequirementKind: UInt8 {
  case `protocol` = 0
  case sameType = 1
  case baseClass = 2
  case sameConformance = 3
  case layout = 0x1F
}

public enum GenericRequirementLayoutKind: UInt32 {
  case `class` = 0
}

struct _ProtocolDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _name: RelativeDirectPointer<CChar>
  let _numRequirementsInSignature: UInt32
  let _numRequirements: UInt32
  let _associatedTypeNames: RelativeDirectPointer<CChar>
}

struct _GenericRequirementDescriptor {
  let _flags: GenericRequirementDescriptor.Flags
  let _param: RelativeDirectPointer<CChar>
  // This field is a union which represents the type of requirement
  // that this parameter is constrained to. It is represented by the following:
  // 1. Same type requirement (RelativeDirectPointer<CChar>)
  // 2. Protocol requirement ()
  // 3. Conformance requirement (RelativeIndirectablePointer<ProtocolConformanceRecord>)
  // 4. Layout requirement (LayoutKind)
  let _requirement: Int32
}

struct _ProtocolConformanceDescriptor {
  let _protocol: RelativeIndirectablePointer<_ProtocolDescriptor>
  let _typeRef: Int32
  let _witnessTablePattern: RelativeDirectPointer<Int>
  //let _flags:
}
