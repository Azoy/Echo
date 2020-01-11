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
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = layout._name.address(from: offset)
    return String(cString: address)
  }
  
  public var numRequirementsInSignature: Int {
    Int(layout._numRequirementsInSignature)
  }
  
  public var numRequirements: Int {
    Int(layout._numRequirements)
  }
  
  public var associatedTypeNames: String {
    let offset = ptr.offset(of: 5, as: Int32.self)
    let address = layout._associatedTypeNames.address(from: offset)
    return String(cString: address)
  }
}

struct _ProtocolDescriptor {
  let _base: _ContextDescriptor
  let _name: RelativeDirectPointer<CChar>
  let _numRequirementsInSignature: UInt32
  let _numRequirements: UInt32
  let _associatedTypeNames: RelativeDirectPointer<CChar>
}

struct _ProtocolConformanceDescriptor {
  let _protocol: RelativeIndirectablePointer<_ProtocolDescriptor>
  let _typeRef: Int32
  let _witnessTablePattern: RelativeDirectPointer<Int>
  //let _flags:
}
