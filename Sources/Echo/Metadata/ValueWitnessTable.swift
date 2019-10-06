//
//  ValueWitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public typealias CFunc = @convention(c) () -> ()

public struct ValueWitnessTable {
  public let initializeBufferWithCopyOfBuffer: UnsafePointer<CFunc>
  public let destroy: UnsafePointer<CFunc>
  public let initializeWithCopy: UnsafePointer<CFunc>
  public let assignWithCopy: UnsafePointer<CFunc>
  public let initializeWithTake: UnsafePointer<CFunc>
  public let assignWithTake: UnsafePointer<CFunc>
  public let getEnumTagSinglePayload: UnsafePointer<CFunc>
  public let storeEnumTagSinglePayload: UnsafePointer<CFunc>
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
  
  public var isInlineStorage: Bool {
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
