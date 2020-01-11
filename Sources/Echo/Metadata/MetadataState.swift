//
//  MetadataState.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

/// The public and current state of a metadata record.
public enum MetadataState: UInt8 {
  /// Complete metadata is the final state for all metadata in which everything
  /// has been initialized and computed for all type operations.
  case complete = 0x0
  
  /// Metadata in this state includes everything in a layout complete state
  /// along with class related instance layout requirements,
  /// initialization, and Objective-C dynamic registration.
  case nonTransitiveComplete = 0x1
  
  /// This metadata has its value witness table computed along with everything
  /// included in the abstract state.
  case layoutComplete = 0x3F
  
  /// Abstract metadata include it's basic type information, but may not include
  /// things like a value witness table. Any references to other types within
  /// the metadata are not created yet (superclass).
  case abstract = 0xFF
}
