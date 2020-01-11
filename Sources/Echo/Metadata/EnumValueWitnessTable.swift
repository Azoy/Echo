//
//  EnumValueWitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct EnumValueWitnessTable: LayoutWrapper {
  typealias Layout = _EnumValueWitnessTable
  
  public let ptr: UnsafeRawPointer
  
  var _enumVwt: _EnumValueWitnessTable {
    ptr.load(as: UnsafePointer<_EnumValueWitnessTable>.self).pointee
  }
  
  public var vwt: ValueWitnessTable {
    ValueWitnessTable(ptr: ptr)
  }
  
  public func getEnumTag(for instance: UnsafeRawPointer) -> UInt32 {
    _enumVwt._getEnumTag(instance, vwt.metadataPtr)
  }
  
  public func destructiveProjectEnumData(for instance: UnsafeRawPointer) {
    _enumVwt._destructiveProjectEnumData(instance, vwt.metadataPtr)
  }
  
  public func destructiveInjectEnumTag(
    for instance: UnsafeRawPointer,
    tag: UInt32
  ) {
    _enumVwt._destructiveInjectEnumTag(instance, tag, vwt.metadataPtr)
  }
}

struct _EnumValueWitnessTable {
  let _vwt: _ValueWitnessTable
  let _getEnumTag: @convention(c) (
    // Enum value
    UnsafeRawPointer,
    // Metadata
    UnsafeRawPointer
  ) -> UInt32 // returns the tag value (which case value in [0..numElements-1])
  let _destructiveProjectEnumData: @convention(c) (
    // Enum value
    UnsafeRawPointer,
    // Metadata
    UnsafeRawPointer
  ) -> ()
  let _destructiveInjectEnumTag: @convention(c) (
    // Enum value
    UnsafeRawPointer,
    // Tag
    UInt32,
    // Metadata
    UnsafeRawPointer
  ) -> ()
}
