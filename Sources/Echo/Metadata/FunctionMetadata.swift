//
//  FunctionMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a function type in Swift.
public struct FunctionMetadata: Metadata, LayoutWrapper {
  typealias Layout = _FunctionMetadata
  
  /// Backing function metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The flags specific to function metadata.
  public var flags: Flags {
    layout._flags
  }
  
  /// The result type for this function.
  public var resultType: Any.Type {
    layout._result
  }
  
  /// The result type metadata for this function.
  public var resultMetadata: Metadata {
    reflect(resultType)
  }
  
  /// An array of parameter types for this function.
  public var paramTypes: [Any.Type] {
    let buffer = UnsafeBufferPointer<Any.Type>(
      start: UnsafePointer<Any.Type>(trailing),
      count: flags.numParams
    )
    return Array(buffer)
  }
  
  /// An array of parameter type metadata for this function.
  public var paramMetadata: [Metadata] {
    paramTypes.map { reflect($0) }
  }
  
  /// An array of parameter flags that describe each parameter for this
  /// function, if any.
  public var paramFlags: [ParamFlags]? {
    guard flags.hasParamFlags else { return nil }
    
    let start = trailing.offset(of: flags.numParams)
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
