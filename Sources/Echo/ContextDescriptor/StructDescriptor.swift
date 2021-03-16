//
//  StructDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// A struct descriptor that describes some structure context.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct StructDescriptor: TypeContextDescriptor, LayoutWrapper {
  typealias Layout = _StructDescriptor
  
  /// Backing context descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The number of stored properties this struct defines.
  public var numFields: Int {
    Int(layout._numFields)
  }
  
  /// The number of words from the metadata pointer to the vector of field
  /// offsets for this struct.
  /// E.g. If this is 2:
  ///   let fieldOffsetVector = metadataPtr + MemoryLayout<Int>.size * 2
  ///   // fieldOffsetVector is a buffer pointer to Int32's that tell the
  ///   // stored offset for a specific field at index i.
  public var fieldOffsetVectorOffset: Int {
    Int(layout._fieldOffsetVectorOffset)
  }
  
  /// The foreign metadata initialization info for this struct metadata, if it
  /// has any.
  public var foreignMetadataInitialization: ForeignMetadataInitialization? {
    guard typeFlags.metadataInitKind == .foreign else {
      return nil
    }
    
    var offset = 0
    
    if flags.isGeneric {
      offset += typeGenericContext.size
    }
    
    return ForeignMetadataInitialization(ptr: trailing + offset)
  }
  
  /// The singleton metadata initialization info for this struct metadata, if it
  /// has any.
  public var singletonMetadataInitialization: SingletonMetadataInitialization? {
    guard typeFlags.metadataInitKind == .singleton else {
      return nil
    }
    
    var offset = 0
    
    if flags.isGeneric {
      offset += typeGenericContext.size
    }
    
    return SingletonMetadataInitialization(ptr: trailing + offset)
  }
}

extension StructDescriptor: Equatable {}

struct _StructDescriptor {
  let _base: _TypeDescriptor
  let _numFields: UInt32
  let _fieldOffsetVectorOffset: UInt32
}
