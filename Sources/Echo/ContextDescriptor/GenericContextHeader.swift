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
  
  public var base: GenericContextDescriptorHeader {
    _header._base
  }
}

struct _TypeGenericContextDescriptorHeader {
  let _instantiationCache: RelativeDirectPointer<Int>
  let _defaultInstantiationPattern: RelativeDirectPointer<Int>
  let _base: GenericContextDescriptorHeader
}

public struct GenericContextDescriptorHeader {
  public let numParams: UInt16
  public let numRequirements: UInt16
  public let numKeyArguments: UInt16
  public let numExtraArguments: UInt16
}
