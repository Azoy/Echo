//
//  GenericContext.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct GenericContext {
  public let ptr: UnsafeRawPointer
  
  public var header: TypeGenericContextDescriptorHeader {
    TypeGenericContextDescriptorHeader(ptr: ptr)
  }
}
