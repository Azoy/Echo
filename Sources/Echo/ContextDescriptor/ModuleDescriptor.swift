//
//  ModuleDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ModuleDescriptor: ContextDescriptor {

  public let ptr: UnsafeRawPointer
  
  var _module: _ModuleDescriptor {
    ptr.load(as: _ModuleDescriptor.self)
  }
  
  public var name: String {
    let address = _module._name.address(from: ptr.offset(of: 2, as: Int32.self))
    return String(cString: UnsafePointer<CChar>(address))
  }
}

struct _ModuleDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _name: RelativeDirectPointer<CChar>
}
