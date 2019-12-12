//
//  FunctionMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct FunctionMetadata: Metadata, LayoutWrapper {
  typealias Layout = _FunctionMetadata
  
  public let ptr: UnsafeRawPointer
 
  public var flags: Flags {
    layout._flags
  }
  
  public var resultMetadata: Metadata {
    reflect(resultType)
  }
  
  public var resultType: Any.Type {
    layout._result
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
    paramMetadata.map { $0.type }
  }
  
  public var paramFlags: [ParamFlags]? {
    guard flags.hasParamFlags else { return nil }
    
    var result = [ParamFlags]()
    
    for i in 0 ..< flags.numParams {
      let address = ptr.offset(of: 3 + flags.numParams)
                       .offset(of: i, as: Int32.self)
      result.append(address.load(as: ParamFlags.self))
    }
    
    return result
  }
}

extension FunctionMetadata {
  public struct Flags {
    public let bits: Int
    
    public var numParams: Int {
      bits & 0xFFFF
    }
    
    public var convention: FunctionConvention {
      FunctionConvention(rawValue: UInt8((bits & 0xFF0000) >> 16))!
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
}

public enum FunctionConvention: UInt8 {
  case swift = 0
  case block = 1
  case thin = 2
  case c = 3
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
  let _flags: FunctionMetadata.Flags
  let _result: Any.Type
}
