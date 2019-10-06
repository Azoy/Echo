//
//  StructContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
//

public struct StructDescriptor: TypeContextDescriptor {
  
  public let ptr: UnsafeRawPointer
  
  public init(ptr: UnsafeRawPointer) {
    self.ptr = ptr
  }
  
}
