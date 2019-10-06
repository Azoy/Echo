//
//  EnumDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public struct EnumDescriptor: TypeContextDescriptor {
  
  public let ptr: UnsafeRawPointer
  
  public init(ptr: UnsafeRawPointer) {
    self.ptr = ptr
  }
  
}
