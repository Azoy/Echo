//
//  ProtocolDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// A protocol descriptor that describes some protocol context.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
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
    Array(unsafeUninitializedCapacity: numRequirementsInSignature) {
      for i in 0 ..< numRequirementsInSignature {
        let address = trailing.offset(
          of: i,
          as: _GenericRequirementDescriptor.self
        )
        
        $0[i] = GenericRequirementDescriptor(ptr: address)
      }
      
      $1 = numRequirementsInSignature
    }
  }
  
  /// An array of all the protocol requirements this protocol defines.
  public var requirements: [ProtocolRequirement] {
    Array(unsafeUninitializedCapacity: numRequirements) {
      let genericReqSize = MemoryLayout<_GenericRequirementDescriptor>.size
      let start = trailing + numRequirementsInSignature * genericReqSize
      
      for i in 0 ..< numRequirements {
        let address = start.offset(of: i, as: _ProtocolRequirement.self)
        $0[i] = ProtocolRequirement(ptr: address)
      }
      
      $1 = numRequirements
    }
  }
}

extension ProtocolDescriptor: Equatable {}

/// A protocol requirement that is defined in some protocol.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct ProtocolRequirement: LayoutWrapper {
  typealias Layout = _ProtocolRequirement
  
  /// Backing protocol requirement pointer.
  let ptr: UnsafeRawPointer
  
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
