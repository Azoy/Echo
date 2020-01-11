//
//  MetadataRequest.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct MetadataRequest {
  public var bits: UInt
  
  public static var complete: MetadataRequest {
    .init(state: .complete)
  }
  
  public init(state: MetadataState, isNonBlocking: Bool = false) {
    bits = UInt(state.rawValue)
    bits |= (isNonBlocking ? 1 : 0) << 8
  }
  
  public var state: MetadataState {
    MetadataState(rawValue: UInt8(bits & 0xFF))!
  }
  
  public var isNonBlocking: Bool {
    bits & 0x100 != 0
  }
}

public struct MetadataResponse {
  public let type: Any.Type
  let _state: UInt8
  
  public var state: MetadataState {
    MetadataState(rawValue: _state)!
  }
}
