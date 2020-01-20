//
//  EnumDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// An enum descriptor that describes some enum context.
public struct EnumDescriptor: TypeContextDescriptor, LayoutWrapper {
  typealias Layout = _EnumDescriptor
  
  /// Backing context descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The number of enum cases which have payloads (associated types).
  /// Ex. case number(Int)
  public var numPayloadCases: Int {
    Int(layout._numPayloadCasesAndPayloadSizeOffset) & 0xFFFFFF
  }
  
  /// The payload size offset is the number of words from the metadata pointer
  /// to the payload size, if any.
  public var payloadSizeOffset: Int {
    Int((layout._numPayloadCasesAndPayloadSizeOffset & 0xFF000000) >> 24)
  }
  
  /// Whether or not this enum has a payload size offset.
  public var hasPayloadSizeOffset: Bool {
    payloadSizeOffset != 0
  }
  
  /// The number of enum cases that have no payload.
  /// Ex. case blue
  public var numEmptyCases: Int {
    Int(layout._numEmptyCases)
  }
  
  /// The total number of cases this enum has.
  public var numCases: Int {
    numEmptyCases + numPayloadCases
  }
}

struct _EnumDescriptor {
  let _base: _TypeDescriptor
  let _numPayloadCasesAndPayloadSizeOffset: UInt32
  let _numEmptyCases: UInt32
}
