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
  
  public var superclassMetadata: Metadata? {
    guard flags.hasSuperclassConstraint else { return nil }
    
    let metadata = ptr.offset(of: 2).load(as: UnsafeRawPointer.self)
    return getMetadata(at: metadata)
  }
  
  public var superclass: Any.Type? {
    return superclassMetadata?.type
  }
  
  public var protocols: [ProtocolDescriptor] {
    var result = [ProtocolDescriptor]()
    
    for i in 0 ..< numProtocols {
      let offset = flags.hasSuperclassConstraint ? 3 : 2
      let address = ptr.offset(of: offset + i).load(as: UnsafeRawPointer.self)
      result.append(ProtocolDescriptor(ptr: address))
    }
    
    return result
  }
}

extension ExistentialMetadata {
  public struct Flags {
    public let bits: UInt32
    
    public var numWitnessTables: Int {
      Int(bits & 0xFFFFFF)
    }
    
    public var specialProtocol: SpecialProtocol {
      SpecialProtocol(rawValue: UInt8((bits & 0x3F000000) >> 24))!
    }
    
    public var hasSuperclassConstraint: Bool {
      bits & 0x40000000 != 0
    }
    
    public var isClassConstraint: Bool {
      // Note this is inverted on purpose
      bits & 0x80000000 == 0
    }
  }
}

public enum SpecialProtocol: UInt8 {
  // Every other protocol
  case none = 0
  
  // Swift.Error
  case error = 1
}

struct _ExistentialMetadata {
  let _kind: Int
  let _flags: ExistentialMetadata.Flags
  let _numProtos: UInt32
}
