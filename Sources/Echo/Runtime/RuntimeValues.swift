//
//  RuntimeValues.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

extension ConformanceDescriptor {
  /// The flags that describe a conformance to a protocol for a type.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// Whether or not the conformance descriptor's witness table pattern is
    /// used as a pattern or if it's served as the real witness table. This is
    /// most likely true when the conformance is about a generic type and false
    /// when the conformance is about a non generic type. Please make sure to
    /// consult this flag beforehand though to make sure.
    public var hasGenericWitnessTable: Bool {
      bits & (0x1 << 17) != 0
    }
    
    /// Whether or not this conformance has resilient witnesses.
    public var hasResilientWitnesses: Bool {
      bits & (0x1 << 16) != 0
    }
    
    /// Whether or not this conformance is retroactive. A conformance is
    /// considered retroactive when it happens in a module that is not the
    /// module the protocol was defined in and not the module the type conforming
    /// was defined in.
    public var isRetroactive: Bool {
      bits & (0x1 << 6) != 0
    }
    
    /// Whether or not this conformance was synthesized non-uniquely. This
    /// happens when an imported C structure or such defines a Swift conformance.
    public var isSynthesizedNonUnique: Bool {
      bits & (0x1 << 7) != 0
    }
    
    /// The number of conditional requirements this conformance requires. This
    /// occurs with conditional conformance situations where a type only conforms
    /// if one/a few/all of its generic parameters conform to some protocol.
    /// Another example is a type conforming to some protocol if it has some
    /// same type requirement.
    public var numConditionalRequirements: Int {
      Int(bits & (0xFF << 8)) >> 8
    }
    
    /// The type reference kind to the type that is conforming to some protocol
    /// in this conformance.
    public var typeReferenceKind: TypeReferenceKind {
      TypeReferenceKind(rawValue: UInt16(bits & (0x7 << 3)) >> 3)!
    }
  }
}
