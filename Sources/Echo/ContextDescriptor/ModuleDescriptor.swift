//
//  ModuleDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public struct ModuleDescriptor: ContextDescriptor {

  public let ptr: UnsafeRawPointer
  
  public var name: String {
    let address = ptr.offset(of: 2, as: Int32.self)
    let relativePtr = RelativeDirectPointer<CChar>(
      ptr: address,
      offset: address.load(as: Int32.self)
    )
    
    return String(cString: UnsafePointer<CChar>(relativePtr.address._rawValue))
  }
  
  public init(ptr: UnsafeRawPointer) {
    self.ptr = ptr
  }
  
}
