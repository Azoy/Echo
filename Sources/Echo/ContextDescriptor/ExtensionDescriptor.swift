//
//  ExtensionDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ExtensionDescriptor: ContextDescriptor {
  public let ptr: UnsafeRawPointer
  
  var _extension: _ExtensionDescriptor {
    ptr.load(as: _ExtensionDescriptor.self)
  }
  
  public var extendedContext: UnsafePointer<CChar> {
    let address = _extension._extendedContext.address(from: ptr)
    return UnsafePointer<CChar>(address)
  }
}

struct _ExtensionDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _extendedContext: RelativeDirectPointer<CChar>
}
