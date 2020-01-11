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
  
  public var resultType: Any.Type {
    layout._result
  }
  
  public var resultMetadata: Metadata {
    reflect(resultType)
  }
  
  public var paramTypes: [Any.Type] {
    let start = ptr.offset(of: 3)
    let buffer = UnsafeBufferPointer<Any.Type>(
      start: UnsafePointer<Any.Type>(start),
      count: flags.numParams
    )
    return Array(buffer)
  }
  
  public var paramMetadata: [Metadata] {
    paramTypes.map { reflect($0) }
  }
  
  public var paramFlags: [ParamFlags]? {
    guard flags.hasParamFlags else { return nil }
    
    let start = ptr.offset(of: 3 + flags.numParams)
    let buffer = UnsafeBufferPointer<ParamFlags>(
      start: UnsafePointer<ParamFlags>(start),
      count: flags.numParams
    )
    return Array(buffer)
  }
}

struct _FunctionMetadata {
  let _kind: Int
  let _flags: FunctionMetadata.Flags
  let _result: Any.Type
}
