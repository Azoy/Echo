//
//  ValueWitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ValueWitnessTable {
  public let ptr: UnsafeRawPointer
  
  var _vwt: _ValueWitnessTable {
    ptr.load(as: UnsafePointer<_ValueWitnessTable>.self).pointee
  }
  
  var metadataPtr: UnsafeRawPointer {
    ptr.offset(of: 1)
  }
  
  public func initializeBufferWithCopyOfBuffer(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._initializeBufferWithCopyOfBuffer(dest, source, metadataPtr)
  }
  
  public func destroy(_ value: UnsafeRawPointer) {
    _vwt._destroy(value, metadataPtr)
  }
  
  public func initializeWithCopy(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._initializeWithCopy(dest, source, metadataPtr)
  }
  
  public func assignWithCopy(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._assignWithCopy(dest, source, metadataPtr)
  }
  
  public func initializeWithTake(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._initializeWithTake(dest, source, metadataPtr)
  }
  
  public func assignWithTake(
    _ dest: UnsafeRawPointer,
    _ source: UnsafeRawPointer
  ) {
    _ = _vwt._assignWithTake(dest, source, metadataPtr)
  }
  
  public func getEnumTagSinglePayload(
    _ instance: UnsafeRawPointer,
    _ numEmptyCases: UInt32
  ) -> UInt32 {
    _vwt._getEnumTagSinglePayload(instance, numEmptyCases, metadataPtr)
  }
  
  public func storeEnumTagSinglePayload(
    _ instance: UnsafeRawPointer,
    _ tag: UInt32,
    _ numEmptyCases: UInt32
  ) {
    _vwt._storeEnumTagSinglePayload(instance, tag, numEmptyCases, metadataPtr)
  }
  
  public var size: Int {
    _vwt._size
  }
  
  public var stride: Int {
    _vwt._stride
  }
  
  public var flags: ValueWitnessTableFlags {
    _vwt._flags
  }
  
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
  let _flags: ValueWitnessTableFlags
  let _extraInhabitantCount: UInt32
}
