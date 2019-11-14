//
//  ExistentialMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ExistentialMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  var _existential: _ExistentialMetadata {
    ptr.load(as: _ExistentialMetadata.self)
  }
  
  public var kind: MetadataKind {
    .existential
  }
  
  public var flags: ExistentialFlags {
    _existential._flags
  }
  
  public var numProtocols: Int {
    Int(_existential._numProtos)
  }
  
  public var superclassMetadata: Metadata? {
    guard flags.hasSuperclassConstraint else { return nil }
    
    let metadata = ptr.offset(of: 2).load(as: UnsafeRawPointer.self)
    return getMetadata(at: metadata)
  }
  
  public var superclass: Any.Type? {
    return superclassMetadata?.type
  }
  
  public var protocols: [ContextDescriptor] {
    var result = [ContextDescriptor]()
    
    for i in 0 ..< numProtocols {
      let offset = flags.hasSuperclassConstraint ? 3 : 2
      let address = ptr.offset(of: offset + i).load(as: UnsafeRawPointer.self)
      result.append(StructDescriptor(ptr: address))
    }
    
    return result
  }
}

public struct ExistentialFlags {
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

public enum SpecialProtocol: UInt8 {
  case none = 0
  
  // Swift.Error
  case error = 1
}

struct _ExistentialMetadata {
  let _kind: Int
  let _flags: ExistentialFlags
  let _numProtos: UInt32
}
