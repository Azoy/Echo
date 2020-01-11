//
//  GenericContext.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct GenericContext: LayoutWrapper {
  typealias Layout = _GenericContextDescriptorHeader
  
  public let ptr: UnsafeRawPointer
  
  public var numParams: Int {
    Int(layout._numParams)
  }
  
  public var numRequirements: Int {
    Int(layout._numRequirements)
  }
  
  public var numKeyArguments: Int {
    Int(layout._numKeyArguments)
  }
  
  public var numExtraArguments: Int {
    Int(layout._numExtraArguments)
  }
  
  var parameterSize: Int {
    (-numParams & 3) + numParams
  }
  
  public var parameters: [GenericParameterDescriptor] {
    let start = ptr + MemoryLayout<_GenericContextDescriptorHeader>.size
    let buffer = UnsafeBufferPointer<GenericParameterDescriptor>(
      start: UnsafePointer<GenericParameterDescriptor>(start),
      count: numParams
    )
    return Array(buffer)
  }
  
  var requiremetSize: Int {
    numRequirements * MemoryLayout<_GenericRequirementDescriptor>.size
  }
  
  public var requirements: [GenericRequirementDescriptor] {
    var result = [GenericRequirementDescriptor]()
    
    for i in 0 ..< numRequirements {
      let parameters = ptr + MemoryLayout<_GenericContextDescriptorHeader>.size
      let requirements = parameters + parameterSize
      let requirementSize = MemoryLayout<_GenericRequirementDescriptor>.size
      let address = requirements + i * requirementSize
      result.append(GenericRequirementDescriptor(ptr: address))
    }
    
    return result
  }
  
  // Number of bytes this generic context is.
  public var size: Int {
    let base = MemoryLayout<_GenericContextDescriptorHeader>.size
    return base + parameterSize + requiremetSize
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
    return layout._param.address(from: offset)
  }
  
  public var mangledTypeName: UnsafePointer<CChar> {
    assert(flags.kind == .sameType || flags.kind == .baseClass)
    let offset = ptr.offset(of: 2, as: Int32.self)
    return offset.relativeDirectAddress(as: CChar.self)
  }
  
  public var `protocol`: ProtocolDescriptor {
    assert(flags.kind == .protocol)
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = offset.relativeIndirectableIntPairAddress(
      as: _ProtocolDescriptor.self,
      and: UInt8.self
    ).raw
    return ProtocolDescriptor(ptr: address)
  }
  
  public var layoutKind: GenericRequirementLayoutKind {
    assert(flags.kind == .layout)
    return GenericRequirementLayoutKind(rawValue: UInt32(layout._requirement))!
  }
}

public struct TypeGenericContext: LayoutWrapper {
  typealias Layout = _TypeGenericContextDescriptorHeader
  
  public let ptr: UnsafeRawPointer
  
  var baseContext: GenericContext {
    GenericContext(ptr: ptr.offset(of: 2, as: Int32.self))
  }
  
  public var numParams: Int {
    baseContext.numParams
  }
  
  public var numRequirements: Int {
    baseContext.numRequirements
  }
  
  public var numKeyArguments: Int {
    baseContext.numKeyArguments
  }
  
  public var numExtraArguments: Int {
    baseContext.numExtraArguments
  }
  
  public var parameters: [GenericParameterDescriptor] {
    baseContext.parameters
  }
  
  public var requirements: [GenericRequirementDescriptor] {
    baseContext.requirements
  }
  
  public var size: Int {
    let base = baseContext.size
    let type = MemoryLayout<_TypeGenericContextDescriptorHeader>.size -
               MemoryLayout<_GenericContextDescriptorHeader>.size
    return base + type
  }
}

struct _GenericContextDescriptorHeader {
  let _numParams: UInt16
  let _numRequirements: UInt16
  let _numKeyArguments: UInt16
  let _numExtraArguments: UInt16
}

struct _GenericRequirementDescriptor {
  let _flags: GenericRequirementDescriptor.Flags
  let _param: RelativeDirectPointer<CChar>
  // This field is a union which represents the type of requirement
  // that this parameter is constrained to. It is represented by the following:
  // 1. Same type requirement (RelativeDirectPointer<CChar>)
  // 2. Protocol requirement (RelativeIndirectablePointerIntPair<ProtocolDescriptor, Bool>)
  // 3. Conformance requirement (RelativeIndirectablePointer<ProtocolConformanceRecord>)
  // 4. Layout requirement (LayoutKind)
  let _requirement: Int32
}

struct _TypeGenericContextDescriptorHeader {
  // Private data for the runtime only.
  let _instantiationCache: RelativeDirectPointer<UnsafeRawPointer>
  let _defaultInstantiationPattern: RelativeDirectPointer<Int>
  let _base: _GenericContextDescriptorHeader
}
