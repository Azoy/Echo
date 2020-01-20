//
//  MetadataAccessFunction.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

// Not quite possible in Swift yet...

/*
public struct MetadataAccessFunction {
  public let ptr: UnsafeRawPointer
  
  public func call0(request: MetadataRequest) -> MetadataResponse {
    let fn = unsafeBitCast(
      ptr,
      to: ((MetadataRequest) -> MetadataResponse).self
    )
    return fn(request)
  }
  
  public func call1(
    request: MetadataRequest,
    type1: Any.Type
  ) -> MetadataResponse {
    let fn = unsafeBitCast(
      ptr,
      to: ((MetadataRequest, Any.Type) -> MetadataResponse).self
    )
    return fn(request, type1)
  }
}
*/
