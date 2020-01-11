//
//  ExistentialMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ExistentialMetadata: Metadata, LayoutWrapper {
  typealias Layout = _ExistentialMetadata
  
  public let ptr: UnsafeRawPointer
  
  public var flags: Flags {
    layout._flags
  }
  
  public var numProtocols: Int {
    Int(layout._numProtos)
  }
  
  public var superclass: Any.Type? {
    guard flags.hasSuperclassConstraint else { return nil }
    
    return ptr.offset(of: 2).load(as: Any.Type.self)
  }
  
  public var superclassMetadata: Metadata? {
    superclass.map { reflect($0) }
  }
  
  public var protocols: [ProtocolDescriptor] {
    let offset = flags.hasSuperclassConstraint ? 3 : 2
    let start = ptr.offset(of: offset)
    let buffer = UnsafeBufferPointer<ProtocolDescriptor>(
      start: UnsafePointer<ProtocolDescriptor>(start),
      count: numProtocols
    )
    return Array(buffer)
  }
}

struct _ExistentialMetadata {
  let _kind: Int
  let _flags: ExistentialMetadata.Flags
  let _numProtos: UInt32
}
