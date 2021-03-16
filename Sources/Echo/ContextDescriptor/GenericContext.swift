//
//  GenericContext.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// A generic context describes the generic information about some generic
/// context.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct GenericContext: LayoutWrapper {
  typealias Layout = _GenericContextDescriptorHeader
  
  /// Backing generic context pointer.
  let ptr: UnsafeRawPointer
  
  /// The number of generic parameters this context has.
  public var numParams: Int {
    Int(layout._numParams)
  }
  
  /// The number of generic requirements this context has.
  public var numRequirements: Int {
    Int(layout._numRequirements)
  }
  
  /// The number of "key" generic parameters this context has.
  public var numKeyArguments: Int {
    Int(layout._numKeyArguments)
  }
  
  /// The number of "extra" generic parameters this context has.
  public var numExtraArguments: Int {
    Int(layout._numExtraArguments)
  }
  
  /// The number of bytes the parameters take up.
  var parameterSize: Int {
    (-numParams & 3) + numParams
  }
  
  /// An array of all the generic parameters this context has.
  public var parameters: [GenericParameterDescriptor] {
    Array(unsafeUninitializedCapacity: numParams) {
      for i in 0 ..< numParams {
        let param = trailing.load(
          fromByteOffset: i * MemoryLayout<GenericParameterDescriptor>.stride,
          as: GenericParameterDescriptor.self
        )
        
        $0[i] = param
      }
      
      $1 = numParams
    }
  }
  
  /// The number of bytes the requirements take up.
  var requirementSize: Int {
    numRequirements * MemoryLayout<_GenericRequirementDescriptor>.size
  }
  
  /// An array of all the generic requirements this context has.
  public var requirements: [GenericRequirementDescriptor] {
    Array(unsafeUninitializedCapacity: numRequirements) {
      for i in 0 ..< numRequirements {
        let requirements = trailing + parameterSize
        let address = requirements.offset(
          of: i,
          as: _GenericRequirementDescriptor.self
        )
        
        $0[i] = GenericRequirementDescriptor(ptr: address)
      }
      
      $1 = numRequirements
    }
  }
  
  /// Number of bytes this generic context is.
  public var size: Int {
    let base = MemoryLayout<_GenericContextDescriptorHeader>.size
    return base + parameterSize + requirementSize
  }
}

/// This descriptor describes any generic requirement in either a generic
/// context or in a protocol's requirement signature.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct GenericRequirementDescriptor: LayoutWrapper {
  typealias Layout = _GenericRequirementDescriptor
  
  /// Backing generic requirement descriptor pointer.
  let ptr: UnsafeRawPointer
  
  /// The flags that describe this generic requirement.
  public var flags: Flags {
    layout._flags
  }
  
  /// The mangled name for this requirement's parameter.
  public var paramMangledName: UnsafeRawPointer {
    address(for: \._param)
  }
  
  /// If this requirement is a sameType or baseClass, this is the mangled name
  /// for the type that's being constrained.
  public var mangledTypeName: UnsafeRawPointer {
    assert(flags.kind == .sameType || flags.kind == .baseClass)
    let addr = address(for: \._requirement)
    return addr.relativeDirectAddress(as: CChar.self)
  }
  
  /// If this requirement is a protocol, this is the protocol descriptor to
  /// said protocol being constrained.
  public var `protocol`: ProtocolDescriptor {
    assert(flags.kind == .protocol)
    let addr = address(for: \._requirement)
    let ptr = SignedPointer<ProtocolDescriptor>(
      ptr: addr.relativeIndirectableIntPairAddress(
        as: _ProtocolDescriptor.self,
        and: UInt8.self
      )
    ).signed
    return ProtocolDescriptor(ptr: ptr)
  }
  
  /// If this requirement is some layout (currently can only be a class),
  /// this is the kind of layout that's being constrained.
  public var layoutKind: GenericRequirementLayoutKind {
    assert(flags.kind == .layout)
    return GenericRequirementLayoutKind(rawValue: UInt32(layout._requirement))!
  }
}

/// A type generic context is an extension of a generic context for contexts
/// that define some type in Swift. Currently that includes structs, classes,
/// and enums. While protocols do define a type, they aren't considered type
/// contexts.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct TypeGenericContext: LayoutWrapper {
  typealias Layout = _TypeGenericContextDescriptorHeader
  
  /// Backing type generic context pointer.
  let ptr: UnsafeRawPointer
  
  /// Grab the base context.
  var baseContext: GenericContext {
    GenericContext(ptr: address(for: \._base))
  }
  
  /// The number of generic parameters this context has.
  public var numParams: Int {
    baseContext.numParams
  }
  
  /// The number of generic requirements this context has.
  public var numRequirements: Int {
    baseContext.numRequirements
  }
  
  /// The number of "key" generic parameters this context has.
  public var numKeyArguments: Int {
    baseContext.numKeyArguments
  }
  
  /// The number of "extra" generic parameters this context has.
  public var numExtraArguments: Int {
    baseContext.numExtraArguments
  }
  
  /// An array of all the generic parameters this context has.
  public var parameters: [GenericParameterDescriptor] {
    baseContext.parameters
  }
  
  /// An array of all the generic requirements this context has.
  public var requirements: [GenericRequirementDescriptor] {
    baseContext.requirements
  }
  
  /// The instantiation pattern for this type generic context.
  public var genericMetadataPattern: GenericMetadataPattern {
    let ptr = address(for: \._defaultInstantiationPattern)
    return GenericMetadataPattern(ptr: ptr)
  }
  
  /// Number of bytes this type generic context is.
  public var size: Int {
    let base = baseContext.size
    let type = MemoryLayout<_TypeGenericContextDescriptorHeader>.size -
               MemoryLayout<_GenericContextDescriptorHeader>.size
    return base + type
  }
}

/// An instantiation pattern for metadata.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct GenericMetadataPattern: LayoutWrapper {
  typealias Layout = _GenericMetadataPattern
  
  /// Backing GenericMetadataPattern pointer.
  let ptr: UnsafeRawPointer
  
  /// The flags that represent this instantiation pattern.
  public var flags: Flags {
    layout._flags
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
  let _defaultInstantiationPattern: RelativeDirectPointer<_GenericMetadataPattern>
  let _base: _GenericContextDescriptorHeader
}

struct _GenericMetadataPattern {
  let _instantiationFunction: RelativeDirectPointer<UnsafeRawPointer>
  let _completionFunction: RelativeDirectPointer<UnsafeRawPointer>
  let _flags: GenericMetadataPattern.Flags
}
