//
//  FunctionMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a function type in Swift.
///
/// ABI Stability: Unstable across all platforms
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | NA    | NA       | NA      | NA    | NA      |
///
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
    Array(unsafeUninitializedCapacity: flags.numParams) {
      for i in 0 ..< flags.numParams {
        let type = trailing.load(
          fromByteOffset: i * MemoryLayout<Any.Type>.size,
          as: Any.Type.self
        )
        
        $0[i] = type
      }
      
      $1 = flags.numParams
    }
  }
  
  /// An array of parameter type metadata for this function.
  public var paramMetadata: [Metadata] {
    paramTypes.map { reflect($0) }
  }
  
  /// An array of parameter flags that describe each parameter for this
  /// function, if any.
  public var paramFlags: [ParamFlags] {
    guard flags.hasParamFlags else { return [] }
    
    return Array(unsafeUninitializedCapacity: flags.numParams) {
      let start = trailing.offset(of: flags.numParams)
      
      for i in 0 ..< flags.numParams {
        let paramFlag = start.load(
          fromByteOffset: i * MemoryLayout<ParamFlags>.stride,
          as: ParamFlags.self
        )
        
        $0[i] = paramFlag
      }
      
      $1 = flags.numParams
    }
  }
}

extension FunctionMetadata: Equatable {}

struct _FunctionMetadata {
  let _kind: Int
  let _flags: FunctionMetadata.Flags
  let _result: Any.Type
}
