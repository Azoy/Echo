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
}

struct _GenericContextDescriptorHeader {
  let _numParams: UInt16
  let _numRequirements: UInt16
  let _numKeyArguments: UInt16
  let _numExtraArguments: UInt16
}

struct _TypeGenericContextDescriptorHeader {
  // Private data for the runtime only.
  let _instantiationCache: RelativeDirectPointer<UnsafeRawPointer>
  let _defaultInstantiationPattern: RelativeDirectPointer<Int>
  let _base: _GenericContextDescriptorHeader
}
