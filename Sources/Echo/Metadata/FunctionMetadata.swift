//
//  FunctionMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct FunctionMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  var _function: _FunctionMetadata {
    ptr.load(as: _FunctionMetadata.self)
  }
  
  public var kind: MetadataKind {
    .function
  }
 
  public var flags: FunctionFlags {
    _function._flags
  }
  
  public var resultMetadata: Metadata {
    getMetadata(at: _function._resultMetadata)
  }
  
  public var resultType: Any.Type {
    unsafeBitCast(_function._resultMetadata, to: Any.Type.self)
  }
  
  public var paramMetadata: [Metadata] {
    var result = [Metadata]()
    
    for i in 0 ..< flags.numParams {
      let metadata = ptr.offset(of: 3 + i).load(as: UnsafeRawPointer.self)
      result.append(getMetadata(at: metadata))
    }
    
    return result
  }
  
  public var paramTypes: [Any.Type] {
    paramMetadata.map {
      unsafeBitCast($0.ptr, to: Any.Type.self)
    }
  }
  
  public var paramFlags: [ParamFlags]? {
    guard flags.hasParamFlags else { return nil }
    
    var result = [ParamFlags]()
    
    for i in 0 ..< flags.numParams {
      let address = ptr.offset(of: 3 + flags.numParams).offset32(of: i)
      result.append(address.load(as: ParamFlags.self))
    }
    
    return result
  }
}

public struct FunctionFlags {
  public let bits: Int
  
  public var numParams: Int {
    bits & 0xFFFF
  }
  
  public var convention: Convention {
    Convention(rawValue: UInt8((bits & 0xFF0000) >> 16))!
  }
  
  public var `throws`: Bool {
    bits & 0x1000000 != 0
  }
  
  public var hasParamFlags: Bool {
    bits & 0x2000000 != 0
  }
  
  public var isEscaping: Bool {
    bits & 0x4000000 != 0
  }
}

extension FunctionFlags {
  public enum Convention: UInt8 {
    case swift = 0
    case block = 1
    case thin = 2
    case c = 3
  }
}

public struct ParamFlags {
  public let bits: UInt32
  
  public var valueOwnership: ValueOwnership {
    ValueOwnership(rawValue: UInt8(bits & 0x7F))!
  }
  
  public var isVariadic: Bool {
    bits & 0x80 != 0
  }
  
  public var isAutoclosure: Bool {
    bits & 0x100 != 0
  }
}

public enum ValueOwnership: UInt8 {
  case `default` = 0
  case `inout` = 1
  case shared = 2
  case owned = 3
}

struct _FunctionMetadata {
  let _kind: Int
  let _flags: FunctionFlags
  let _resultMetadata: UnsafeRawPointer
}
