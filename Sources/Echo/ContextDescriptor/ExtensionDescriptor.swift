//
//  ExtensionDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

/// An extension descriptor that describes some extension context.
public struct ExtensionDescriptor: ContextDescriptor, LayoutWrapper {
  typealias Layout = _ExtensionDescriptor
  
  /// Backing context descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The mangled name which this extension extends.
  /// Ex. If this extension extends Int, this mangled name might be
  ///     Si or some symbolic reference to Int's context descriptor.
  public var extendedContext: UnsafePointer<CChar> {
    let offset = ptr.offset(of: 2, as: Int32.self)
    return layout._extendedContext.address(from: offset)
  }
}

struct _ExtensionDescriptor {
  let _base: _ContextDescriptor
  let _extendedContext: RelativeDirectPointer<CChar>
}
