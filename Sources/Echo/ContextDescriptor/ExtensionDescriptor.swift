//
//  ExtensionDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ExtensionDescriptor: ContextDescriptor, LayoutWrapper {
  typealias Layout = _ExtensionDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var extendedContext: UnsafePointer<CChar> {
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = layout._extendedContext.address(from: offset)
    return UnsafePointer<CChar>(address)
  }
}

struct _ExtensionDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _extendedContext: RelativeDirectPointer<CChar>
}
