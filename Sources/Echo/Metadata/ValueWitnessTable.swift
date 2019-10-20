//
//  ValueWitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ValueWitnessTable {
  public let initializeBufferWithCopyOfBuffer: @convention(c) (
    // Destination buffer
    UnsafeRawPointer,
    // Source buffer
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination value
  
  public let destroy: @convention(c) (
    // Value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> ()
  
  public let initializeWithCopy: @convention(c) (
    // Destination value
    UnsafeRawPointer,
    // Source value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination
  
  public let assignWithCopy: @convention(c) (
    // Destination value
    UnsafeRawPointer,
    // Source value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination
  
  public let initializeWithTake: @convention(c) (
    // Destination value
    UnsafeRawPointer,
    // Source value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination
  
  public let assignWithTake: @convention(c) (
    // Destination value
    UnsafeRawPointer,
    // Source value
    UnsafeRawPointer,
    // Type metadata
    UnsafeRawPointer
  ) -> UnsafeRawPointer // returns destination
  
  public let getEnumTagSinglePayload: @convention(c) (
    // Instance of single payload enum
    UnsafeRawPointer,
    // Number of empty cases
    UInt32,
    // Type metadata
    UnsafeRawPointer
  ) -> UInt32 // returns tag of enum
  public let storeEnumTagSinglePayload: @convention(c) (
    // Instance of single payload enum
    UnsafeRawPointer,
    // Which enum case
    UInt32,
    // Number of empty cases
    UInt32,
    // Type metadata
    UnsafeRawPointer
  ) -> ()
  
  public let size: Int
  public let stride: Int
  public let flags: ValueWitnessTableFlags
  public let extraInhabitantCount: UInt32
}

public struct ValueWitnessTableFlags {
  enum Flags: UInt32 {
    case isNonPOD            = 0x010000
    case isNonInline         = 0x020000
    // unused                = 0x040000
    case hasSpareBits        = 0x080000
    case isNonBitwiseTakable = 0x100000
    case hasEnumWitnesses    = 0x200000
    case incomplete          = 0x400000
  }
  
  let bits: UInt32
  
  public var alignment: Int {
    alignmentMask + 1
  }
  
  var alignmentMask: Int {
    Int(bits & 0xFF)
  }
  
  public var isValueInline: Bool {
    bits & Flags.isNonInline.rawValue == 0
  }
  
  public var isPOD: Bool {
    bits & Flags.isNonPOD.rawValue == 0
  }
  
  public var isBitwiseTakable: Bool {
    bits & Flags.isNonBitwiseTakable.rawValue == 0
  }
  
  public var hasEnumWitnesses: Bool {
    bits & Flags.hasEnumWitnesses.rawValue != 0
  }
  
  public var isIncomplete: Bool {
    bits & Flags.incomplete.rawValue != 0
  }
  
}
