//
//  ProtocolDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// A protocol descriptor that describes some protocol context.
public struct ProtocolDescriptor: ContextDescriptor, LayoutWrapper {
  typealias Layout = _ProtocolDescriptor
  
  /// Backing context descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The specific flags that describe a protocol descriptor.
  public var protocolFlags: Flags {
    Flags(bits: flags.kindSpecificFlags)
  }
  
  /// The name of this protocol.
  public var name: String {
    address(for: \._name).string
  }
  
  /// The number of generic requirements in this protocol's signature.
  public var numRequirementsInSignature: Int {
    Int(layout._numRequirementsInSignature)
  }
  
  /// The number of protocol requirements this protocol defines.
  public var numRequirements: Int {
    Int(layout._numRequirements)
  }
  
  /// A string of all associatedtype names.
  public var associatedTypeNames: String {
    address(for: \._associatedTypeNames).string
  }
  
  /// An array of all the generic requirements in this protocol's signature.
  public var requirementSignature: [GenericRequirementDescriptor] {
    var result = [GenericRequirementDescriptor]()
    
    for i in 0 ..< numRequirementsInSignature {
      let requirementSize = MemoryLayout<_GenericRequirementDescriptor>.size
      let address = trailing + i * requirementSize
      result.append(GenericRequirementDescriptor(ptr: address))
    }
    
    return result
  }
  
  /// An array of all the protocol requirements this protocol defines.
  public var requirements: [ProtocolRequirement] {
    var result = [ProtocolRequirement]()
    
    for i in 0 ..< numRequirements {
      let requirementSize = MemoryLayout<_ProtocolRequirement>.size
      let genericReqSize = MemoryLayout<_GenericRequirementDescriptor>.size
      let start = trailing + numRequirementsInSignature * genericReqSize
      let address = start + i * requirementSize
      result.append(ProtocolRequirement(ptr: address))
    }
    
    return result
  }
}

/// A protocol requirement that is defined in some protocol.
public struct ProtocolRequirement: LayoutWrapper {
  typealias Layout = _ProtocolRequirement
  
  /// Backing protocol requirement pointer.
  public let ptr: UnsafeRawPointer
  
  /// The flags that describe this protocol requirement.
  public var flags: Flags {
    layout._flags
  }
}

struct _ProtocolDescriptor {
  let _base: _ContextDescriptor
  let _name: RelativeDirectPointer<CChar>
  let _numRequirementsInSignature: UInt32
  let _numRequirements: UInt32
  let _associatedTypeNames: RelativeDirectPointer<CChar>
}

struct _ProtocolRequirement {
  let _flags: ProtocolRequirement.Flags
  let _defaultImpl: RelativeDirectPointer<()>
}
