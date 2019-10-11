//
//  ModuleDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public struct ModuleDescriptor: ContextDescriptor {

  public let ptr: UnsafeRawPointer
  
  var _descriptor: _ModuleDescriptor {
    ptr.load(as: _ModuleDescriptor.self)
  }
  
  public var name: String {
    let address = _descriptor._name.address(from: ptr.offset32(of: 2))
    return String(cString: UnsafePointer<CChar>(address._rawValue))
  }
}

struct _ModuleDescriptor {
  let _flags: ContextDescriptorFlags
  let _parent: RelativeIndirectablePointer<_Descriptor>
  let _name: RelativeDirectPointer<CChar>
}
