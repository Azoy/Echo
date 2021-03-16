//
//  AnonymousDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// An anonymous descriptor describes a context which is anonymous, like a
/// function or a private declaration will have an anonymous parent context.
///
/// ABI Stability:
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct AnonymousDescriptor: ContextDescriptor, LayoutWrapper {
  typealias Layout = _ContextDescriptor
  
  // Backing context descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The specific flags that describe an anonymous descriptor.
  public var anonymousFlags: Flags {
    Flags(bits: layout._flags.kindSpecificFlags)
  }
  
  /// The trailing mangled name for the anonymous context.
  public var mangledName: String? {
    guard anonymousFlags.hasMangledName else {
      return nil
    }
    
    var offset = trailing
    
    // If this context isn't generic, then the only trailing member is the
    // mangled name. Otherwise, we need to calculate how large the generic
    // context is and find the mangled name after it.
    if flags.isGeneric {
      offset += genericContext!.size
    }
  
    let address = offset.relativeDirectAddress(as: CChar.self)
    return address.string
  }
}

extension AnonymousDescriptor: Equatable {}

