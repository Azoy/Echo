//
//  EnumValueWitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The value witness table for enums that have enum specific value witness
/// functions.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct EnumValueWitnessTable: LayoutWrapper {
  typealias Layout = SignedPointer<ValueWitnessTable>
  
  /// Backing enum value witness table pointer.
  let ptr: UnsafeRawPointer
  
  var _enumVwt: _EnumValueWitnessTable {
    layout.signed.load(as: _EnumValueWitnessTable.self)
  }
  
  /// The base value witness table.
  public var vwt: ValueWitnessTable {
    ValueWitnessTable(ptr: ptr)
  }
  
  /// Given an instance of an enum, retrieve the "tag", the number that
  /// determines which case is currently being inhabited.
  /// - Parameter instance: An enum instance of the type this value witness
  ///                       resides in.
  /// - Returns: The tag number for which case is being inhabited.
  public func getEnumTag(for instance: UnsafeRawPointer) -> UInt32 {
    #if _ptrauth(_arm64e)
    return echo_vwt_getEnumTag(layout.signed, instance, trailing)
    #else
    return _enumVwt._getEnumTag(instance, trailing)
    #endif
  }
  
  /// Given an instance of an enum, destructively remove the payload.
  /// - Parameter instance: An enum instance of the type this value witness
  ///                       resides in.
  public func destructiveProjectEnumData(
    for instance: UnsafeMutableRawPointer
  ) {
    #if _ptrauth(_arm64e)
    echo_vwt_destructiveProjectEnumData(layout.signed, instance, trailing)
    #else
    _enumVwt._destructiveProjectEnumData(instance, trailing)
    #endif
  }
  
  /// Given an instance of an enum and a case tag, destructively inject the tag
  /// into the enum instance.
  /// - Parameter instance: An enum instance of the type this value witness
  ///                       resides in.
  /// - Parameter tag: A case tag value within [0..numCases)
  public func destructiveInjectEnumTag(
    for instance: UnsafeMutableRawPointer,
    tag: UInt32
  ) {
    #if _ptrauth(_arm64e)
    echo_vwt_destructiveInjectEnumTag(layout.signed, instance, tag, trailing)
    #else
    _enumVwt._destructiveInjectEnumTag(instance, tag, trailing)
    #endif
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
    UnsafeMutableRawPointer,
    // Metadata
    UnsafeRawPointer
  ) -> ()
  let _destructiveInjectEnumTag: @convention(c) (
    // Enum value
    UnsafeMutableRawPointer,
    // Tag
    UInt32,
    // Metadata
    UnsafeRawPointer
  ) -> ()
}
