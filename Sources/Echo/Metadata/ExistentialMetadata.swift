//
//  ExistentialMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents some existential type, mainly
/// `protocol`s, in Swift.
///
/// ABI Stability: Unstable across all platforms
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | NA    | NA       | NA      | NA    | NA      |
///
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
    Array(unsafeUninitializedCapacity: numProtocols) {
      var start = trailing
      
      if flags.hasSuperclassConstraint {
        start = start.offset(of: 1)
      }
      
      for i in 0 ..< numProtocols {
        let proto = start.load(
          fromByteOffset: i * MemoryLayout<ProtocolDescriptor>.size,
          as: ProtocolDescriptor.self
        )
        
        $0[i] = proto
      }
      
      $1 = numProtocols
    }
  }
}

extension ExistentialMetadata: Equatable {}

struct _ExistentialMetadata {
  let _kind: Int
  let _flags: ExistentialMetadata.Flags
  let _numProtos: UInt32
}
