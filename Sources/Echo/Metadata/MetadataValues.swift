//
//  MetadataValues.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

public enum MetadataKind: Int {
  case `class` = 0
  
  // (0 | Flags.isNonHeap)
  case `struct` = 512
  
  // (1 | Flags.isNonHeap)
  case `enum` = 513
  
  // (2 | Flags.isNonHeap)
  case optional = 514
  
  // (3 | Flags.isNonHeap)
  case foreignClass = 515
  
  // (0 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case opaque = 768
  
  // (1 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case tuple = 769
  
  // (2 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case function = 770
  
  // (3 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case existential = 771
  
  // (4 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case metatype = 772
  
  // (5 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case objcClassWrapper = 773
  
  // (6 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case existentialMetatype = 774
  
  // (0 | Flags.isNonType)
  case heapLocalVariable = 1024
  
  // (0 | Flags.isRuntimePrivate | Flags.isNonType)
  case heapGenericLocalVariable = 1280
  
  // (1 | Flags.isRuntimePrivate | Flags.isNonType)
  case errorObject = 1281
}

extension MetadataKind {
  public enum Flags: Int {
    case isRuntimePrivate = 0x100
    case isNonHeap = 0x200
    case isNonType = 0x400
  }
}

extension ClassMetadata {
  public struct Flags {
    public let bits: UInt32
    
    public var isSwiftPreStableABI: Bool {
      bits & 0x1 != 0
    }
    
    public var usesSwiftRefCounting: Bool {
      bits & 0x2 != 0
    }
    
    public var hasCustomObjCName: Bool {
      bits & 0x4 != 0
    }
  }
}

extension ExistentialMetadata {
  public struct Flags {
    public let bits: UInt32
    
    public var numWitnessTables: Int {
      Int(bits & 0xFFFFFF)
    }
    
    public var specialProtocol: SpecialProtocol {
      SpecialProtocol(rawValue: UInt8((bits & 0x3F000000) >> 24))!
    }
    
    public var hasSuperclassConstraint: Bool {
      bits & 0x40000000 != 0
    }
    
    public var isClassConstraint: Bool {
      // Note this is inverted on purpose
      bits & 0x80000000 == 0
    }
  }
}

public enum SpecialProtocol: UInt8 {
  // Every other protocol
  case none = 0
  
  // Swift.Error
  case error = 1
}

extension FunctionMetadata {
  public struct Flags {
    public let bits: Int
    
    public var numParams: Int {
      bits & 0xFFFF
    }
    
    public var convention: FunctionConvention {
      FunctionConvention(rawValue: UInt8((bits & 0xFF0000) >> 16))!
    }
    
    public var `throws`: Bool {
      bits & 0x1000000 != 0
    }
    
    public var hasParamFlags: Bool {
      bits & 0x2000000 != 0
    }
    
    public var isEscaping: Bool {
      bits & 0x4000000 != 0
    }
  }
}

public enum FunctionConvention: UInt8 {
  case swift = 0
  case block = 1
  case thin = 2
  case c = 3
}

public struct ParamFlags {
  public let bits: UInt32
  
  public var valueOwnership: ValueOwnership {
    ValueOwnership(rawValue: UInt8(bits & 0x7F))!
  }
  
  public var isVariadic: Bool {
    bits & 0x80 != 0
  }
  
  public var isAutoclosure: Bool {
    bits & 0x100 != 0
  }
}

public enum ValueOwnership: UInt8 {
  case `default` = 0
  case `inout` = 1
  case shared = 2
  case owned = 3
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
