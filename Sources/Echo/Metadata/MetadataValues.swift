//
//  MetadataValues.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

/// A discriminator that determines what type of metadata this is.
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
  enum Flags: Int {
    case isRuntimePrivate = 0x100
    case isNonHeap = 0x200
    case isNonType = 0x400
  }
}

/// The public and current state of a metadata record.
public enum MetadataState: UInt8 {
  /// Complete metadata is the final state for all metadata in which everything
  /// has been initialized and computed for all type operations.
  case complete = 0x0
  
  /// Metadata in this state includes everything in a layout complete state
  /// along with class related instance layout requirements,
  /// initialization, and Objective-C dynamic registration.
  case nonTransitiveComplete = 0x1
  
  /// This metadata has its value witness table computed along with everything
  /// included in the abstract state.
  case layoutComplete = 0x3F
  
  /// Abstract metadata include it's basic type information, but may not include
  /// things like a value witness table. Any references to other types within
  /// the metadata are not created yet (superclass).
  case abstract = 0xFF
}

extension ClassMetadata {
  /// The flags that describe some class metadata.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// Whether this class uses pre Swift 5.0 ABI.
    public var isSwiftPreStableABI: Bool {
      bits & 0x1 != 0
    }
    
    /// Whether this class uses Swift's native reference counting mechanism.
    public var usesSwiftRefCounting: Bool {
      bits & 0x2 != 0
    }
    
    /// Whether this class has a custom Objective-C name.
    public var hasCustomObjCName: Bool {
      bits & 0x4 != 0
    }
  }
}

extension ExistentialMetadata {
  /// The flags that describe some existential metadata.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// The number of witness tables that are needed for this existential.
    public var numWitnessTables: Int {
      Int(bits & 0xFFFFFF)
    }
    
    /// The kind of special protocol this is.
    public var specialProtocol: SpecialProtocol {
      SpecialProtocol(rawValue: UInt8((bits & 0x3F000000) >> 24))!
    }
    
    /// Whether this existential has a superclass constraint.
    public var hasSuperclassConstraint: Bool {
      bits & 0x40000000 != 0
    }
    
    /// Whether this existential is class constrained. E.g. AnyObject constraint.
    public var isClassConstraint: Bool {
      // Note this is inverted on purpose
      bits & 0x80000000 == 0
    }
  }
}

/// A discriminator to determine the special protocolness of an existential.
public enum SpecialProtocol: UInt8 {
  /// Every other protocol (not special at all, sorry.)
  case none = 0
  
  /// Swift.Error
  case error = 1
}

extension FunctionMetadata {
  /// The flags that describe some function metadata.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: Int
    
    /// The number of parameters in this function.
    public var numParams: Int {
      bits & 0xFFFF
    }
    
    /// The calling convention for this function.
    public var convention: FunctionConvention {
      FunctionConvention(rawValue: UInt8((bits & 0xFF0000) >> 16))!
    }
    
    /// Whether or not this function throws.
    public var `throws`: Bool {
      bits & 0x1000000 != 0
    }
    
    /// Whether or not this function has parameter flags describing the
    /// parameters.
    public var hasParamFlags: Bool {
      bits & 0x2000000 != 0
    }
    
    /// Whether or not this function is @escaping.
    public var isEscaping: Bool {
      bits & 0x4000000 != 0
    }
  }
}

/// A discriminator to determine what calling convention a function has.
public enum FunctionConvention: UInt8 {
  case swift = 0
  case block = 1
  case thin = 2
  case c = 3
}

extension FunctionMetadata {
  /// The flags that represent some function parameter.
  public struct ParamFlags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// The value ownership kind for this parameter.
    public var valueOwnership: ValueOwnership {
      ValueOwnership(rawValue: UInt8(bits & 0x7F))!
    }
    
    /// Whether or not this parameter is variadic. E.g. Int...
    public var isVariadic: Bool {
      bits & 0x80 != 0
    }
    
    /// Whether or not this parameter is marked @autoclosure
    public var isAutoclosure: Bool {
      bits & 0x100 != 0
    }
  }
}

/// A discriminator to determine what the ownership rules are (currently) for
/// a function parameter.
public enum ValueOwnership: UInt8 {
  /// The default ownership rule for all Swift parameters, which might mean
  /// shared or owned.
  case `default` = 0
  
  /// Inout refers to passing a value by reference for mutation.
  case `inout` = 1
  
  /// Shared refers to passing a value by reference, but without mutation.
  /// Similar to Rust's immutable borrow.
  case shared = 2
  
  /// Owned refers to passing a value via copy.
  case owned = 3
}

extension ValueWitnessTable {
  /// The flags that describe some value witness table.
  public struct Flags {
    enum Flags: UInt32 {
      case isNonPOD            = 0x010000
      case isNonInline         = 0x020000
      // unused                = 0x040000
      case hasSpareBits        = 0x080000
      case isNonBitwiseTakable = 0x100000
      case hasEnumWitnesses    = 0x200000
      case incomplete          = 0x400000
    }
    
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// The alignment for this type.
    public var alignment: Int {
      alignmentMask + 1
    }
    
    var alignmentMask: Int {
      Int(bits & 0xFF)
    }
    
    /// Whether or not this value can be stored inline in an existential
    /// container.
    public var isValueInline: Bool {
      bits & Flags.isNonInline.rawValue == 0
    }
    
    /// Whether or not this type is a "plain old datatype"
    public var isPOD: Bool {
      bits & Flags.isNonPOD.rawValue == 0
    }
    
    /// Whether or not this type is bitwise takable.
    public var isBitwiseTakable: Bool {
      bits & Flags.isNonBitwiseTakable.rawValue == 0
    }
    
    /// Whether or not this value witness table has enum witnesses. This is only
    /// true for enum and optional metadata.
    public var hasEnumWitnesses: Bool {
      bits & Flags.hasEnumWitnesses.rawValue != 0
    }
    
    /// Whether or not this value witness table is incomplete.
    public var isIncomplete: Bool {
      bits & Flags.incomplete.rawValue != 0
    }
  }
}
