//
//  ExistentialMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents some existential type, mainly
/// `protocol`s, in Swift.
public struct ExistentialMetadata: Metadata, LayoutWrapper {
  typealias Layout = _ExistentialMetadata
  
  /// Backing existential metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The flags specific to existential metadata.
  public var flags: Flags {
    layout._flags
  }
  
  /// The number of protocols that compose this existential type.
  public var numProtocols: Int {
    Int(layout._numProtos)
  }
  
  /// The superclass type that this existential is constrained to, if any.
  public var superclass: Any.Type? {
    guard flags.hasSuperclassConstraint else { return nil }
    
    return trailing.load(as: Any.Type.self)
  }
  
  /// The superclass metadata that this existential is constrained to, if any.
  public var superclassMetadata: Metadata? {
    superclass.map { reflect($0) }
  }
  
  /// An array of protocols that make up this existential.
  public var protocols: [ProtocolDescriptor] {
    var start = trailing
    
    if flags.hasSuperclassConstraint {
      start = start.offset(of: 1)
    }
    
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
