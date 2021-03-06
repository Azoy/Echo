//
//  MetadataRequest.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// A metadata request is a "request" to a runtime function that returns some
/// metadata in some state, either blocking until the runtime can produce said
/// metadata, or non-blocking returning an abstract metadata record.
public struct MetadataRequest {
  /// A request as represented in bits.
  public var bits: Int
  
  /// The go to metadata request kind which asks for complete metadata blocking
  /// until it returns.
  public static var complete: MetadataRequest {
    .init(state: .complete)
  }
  
  /// Initializes a metadata request with a given state and blocking info.
  /// - Parameter state: The metadata state that is being requested.
  /// - Parameter isNonBlocking: Whether this request doesn't block or not.
  public init(state: MetadataState, isNonBlocking: Bool = false) {
    bits = Int(state.rawValue)
    bits |= (isNonBlocking ? 1 : 0) << 8
  }
  
  /// The metadata state that is being requested with this request.
  public var state: MetadataState {
    MetadataState(rawValue: UInt8(bits & 0xFF))!
  }
  
  /// Whether this request doesn't block or not.
  public var isNonBlocking: Bool {
    bits & 0x100 != 0
  }
}

/// A metadata response is the return type for some runtime functions that
/// either produce metadata or check it.
public struct MetadataResponse {
  /// The type for the metadata requested.
  public let type: Any.Type
  
  /// The internal state value of this metadata.
  let _state: Int
  
  /// The metadata requested.
  public var metadata: Metadata {
    reflect(type)
  }
  
  /// The metadata state of the returned metadata record.
  public var state: MetadataState {
    MetadataState(rawValue: UInt8(_state))!
  }
}
