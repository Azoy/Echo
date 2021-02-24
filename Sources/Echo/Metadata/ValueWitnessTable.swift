//
//  ValueWitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The value witness table is a table of function pointers that describe how
/// to properly copy, destroy, etc. memory for a given type. It also contains
/// type layout information about the type including size, stride, and
/// alignment.
public struct ValueWitnessTable: LayoutWrapper {
  typealias Layout = UnsafePointer<_ValueWitnessTable>
  
  /// Backing value witness table pointer.
  let ptr: UnsafeRawPointer
  
  var _vwt: _ValueWitnessTable {
    layout.pointee
  }
  
  /// Given a buffer an instance of the type in the source buffer, initialize
  /// the destination buffer with a copy of the source.
  /// - Parameter dest: The desintation buffer.
  /// - Parameter source: The source buffer with the instance.
  public func initializeBufferWithCopyOfBuffer(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._initializeBufferWithCopyOfBuffer(dest, source, trailing)
  }
  
  /// Given an instance of this type, destroy it. The resulting pointer is now
  /// an invalid instance.
  /// - Parameter value: An instance of this type.
  public func destroy(_ value: UnsafeRawPointer) {
    _vwt._destroy(value, trailing)
  }
  
  /// Given an invalid instance of this type and a valid instance of this type,
  /// copy the source instance into the destination.
  /// - Parameter dest: An invalid instance of type.
  /// - Parameter source: An instance of type.
  public func initializeWithCopy(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._initializeWithCopy(dest, source, trailing)
  }
  
  /// Given a valid instance of this type and another valid instance of this
  /// type, copy the contents from the source into the destination.
  /// - Parameter dest: An instance of type whose contents are going to be
  ///                   overwritten.
  /// - Parameter source: An instance of type.
  public func assignWithCopy(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._assignWithCopy(dest, source, trailing)
  }
  
  /// Given an invalid instance of this type and a valid instance of this type,
  /// initialize the destination by destroying the source instance.
  /// - Parameter dest: An invalid instance of type.
  /// - Parameter source: An instance of type.
  public func initializeWithTake(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._initializeWithTake(dest, source, trailing)
  }
  
  /// Given a valid instance of this type and another valid instance of this
  /// type, copy the contents from the source instance into the destination
  /// while also destroying the source instance.
  /// - Parameter dest: An instance of type.
  /// - Parameter source: An instance of type.
  public func assignWithTake(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._assignWithTake(dest, source, trailing)
  }
  
  /// Given an instance of an enum case who has a single payload of this type,
  /// get the case tag of the enum.
  /// - Parameter instance: The enum case instance.
  /// - Parameter numEmptyCases: The number of cases without payloads in this
  ///                            enum.
  /// - Returns: The enum case tag for the payload containing this type.
  public func getEnumTagSinglePayload(
    _ instance: UnsafeRawPointer,
    _ numEmptyCases: UInt32
  ) -> UInt32 {
    _vwt._getEnumTagSinglePayload(instance, numEmptyCases, trailing)
  }
  
  /// Given some uninitialzed data of an enum case who has a single payload of
  /// this type, store the tag in the data.
  /// - Parameter instance: The uninitialized instance of the enum case.
  /// - Parameter tag: The enum case tag number for the payload with this type.
  /// - Parameter numEmptyCases: The number of cases without payloads in this
  ///                            enum.
  public func storeEnumTagSinglePayload(
    _ instance: UnsafeRawPointer,
    _ tag: UInt32,
    _ numEmptyCases: UInt32
  ) {
    _vwt._storeEnumTagSinglePayload(instance, tag, numEmptyCases, trailing)
  }
  
  /// The size in bytes that this type represents in memory.
  public var size: Int {
    _vwt._size
  }
  
  /// The required size in bytes needed to represent an element if this type
  /// were in an array.
  public var stride: Int {
    _vwt._stride
  }
  
  /// The flags describing this value witness table.
  public var flags: Flags {
    _vwt._flags
  }
  
  /// The number of extra inhabitants in this type.
  public var extraInhabitantCount: Int {
    Int(_vwt._extraInhabitantCount)
  }
}

struct _ValueWitnessTable {
  let _initializeBufferWithCopyOfBuffer: @convention(c) (
    // Destination buffer
    UnsafeRawPointer,
    // Source buffer
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination value
  
  let _destroy: @convention(c) (
    // Value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> ()
  
  let _initializeWithCopy: @convention(c) (
    // Destination value
    UnsafeRawPointer,
    // Source value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination
  
  let _assignWithCopy: @convention(c) (
    // Destination value
    UnsafeRawPointer,
    // Source value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination
  
  let _initializeWithTake: @convention(c) (
    // Destination value
    UnsafeRawPointer,
    // Source value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination
  
  let _assignWithTake: @convention(c) (
    // Destination value
    UnsafeRawPointer,
    // Source value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination
  
  let _getEnumTagSinglePayload: @convention(c) (
    // Instance of single payload enum
    UnsafeRawPointer,
    // Number of empty cases
    UInt32,
    // Type metadata
    UnsafeRawPointer
  ) -> UInt32 // returns tag of enum
  
  let _storeEnumTagSinglePayload: @convention(c) (
    // Instance of single payload enum
    UnsafeRawPointer,
    // Which enum case
    UInt32,
    // Number of empty cases
    UInt32,
    // Type metadata
    UnsafeRawPointer
  ) -> ()
  
  let _size: Int
  let _stride: Int
  let _flags: ValueWitnessTable.Flags
  let _extraInhabitantCount: UInt32
}
