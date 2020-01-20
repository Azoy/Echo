//
//  HeapObject.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// Some object whose value is being stored on the heap and is being reference
/// counted by the Swift runtime.
public struct HeapObject {
  /// The type being stored in this heap object.
  public let type: Any.Type
  
  /// This isn't exposed because I haven't created the structure that
  /// correctly represents a heap objects ref count yet.
  let _refCount: UInt64
  
  /// The metadata for the type being stored in this heap object.
  public var metadata: Metadata {
    reflect(type)
  }
}
