//
//  GenericContextHeader.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct TypeGenericContextDescriptorHeader {
  public let ptr: UnsafeRawPointer
  
  var _header: _TypeGenericContextDescriptorHeader {
    ptr.load(as: _TypeGenericContextDescriptorHeader.self)
  }
  
  public var numParams: Int {
    Int(_header._base._numParams)
  }
  
  public var numRequirements: Int {
    Int(_header._base._numRequirements)
  }
  
  public var numKeyArguments: Int {
    Int(_header._base._numKeyArguments)
  }
  
  public var numExtraArguments: Int {
    Int(_header._base._numExtraArguments)
  }
}

struct _TypeGenericContextDescriptorHeader {
  let _instantiationCache: RelativeDirectPointer<Int>
  let _defaultInstantiationPattern: RelativeDirectPointer<Int>
  let _base: _GenericContextDescriptorHeader
}

struct _GenericContextDescriptorHeader {
  let _numParams: UInt16
  let _numRequirements: UInt16
  let _numKeyArguments: UInt16
  let _numExtraArguments: UInt16
}
