//
//  AnonymousDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct AnonymousDescriptor: ContextDescriptor {
  public let ptr: UnsafeRawPointer
  
  var _anonymous: _AnonymousDescriptor {
    ptr.load(as: _AnonymousDescriptor.self)
  }
  
  public var anonymousFlags: AnonymousFlags {
    AnonymousFlags(bits: _anonymous._flags.kindSpecificFlags)
  }
}

public struct AnonymousFlags {
  public let bits: UInt16
  
  public var hasMangledName: Bool {
    bits & 0x1 != 0
  }
}

struct _AnonymousDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
}
