//
//  ValueMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public protocol ValueMetadata: Metadata {
  associatedtype Descriptor: ContextDescriptor
  
  var contextDescriptor: Descriptor { get }
}

extension ValueMetadata {
  public var contextDescriptor: Descriptor {
    let address = ptr.offset(of: 1, as: Int.self)
    return Descriptor(ptr: address.load(as: UnsafeRawPointer.self))
  }
}
