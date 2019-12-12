//
//  AnonymousDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

/// An anonymous descriptor describes a context which is anonymous, like a
/// function or a private declaration will have an anonymous parent context.
public struct AnonymousDescriptor: ContextDescriptor, LayoutWrapper {
  typealias Layout = _AnonymousDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var anonymousFlags: Flags {
    Flags(bits: layout._flags.kindSpecificFlags)
  }
  
  public var mangledName: String? {
    guard anonymousFlags.hasMangledName else {
      return nil
    }
    
    guard flags.isGeneric else {
      let offset = ptr + MemoryLayout<_AnonymousDescriptor>.size
      let relativePointer = RelativeDirectPointer<CChar>(
        offset: offset.load(as: Int32.self)
      )
      let address = relativePointer.address(from: offset)
      return String(cString: UnsafePointer<CChar>(address))
    }
    
    return nil
  }
}

struct _AnonymousDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
}
