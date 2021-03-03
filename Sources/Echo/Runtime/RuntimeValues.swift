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
    
    public var hasGenericWitnessTable: Bool {
      bits & (0x1 << 17) != 0
    }
    
    public var hasResilientWitnesses: Bool {
      bits & (0x1 << 16) != 0
    }
    
    public var isRetroactive: Bool {
      bits & (0x1 << 6) != 0
    }
    
    public var isSynthesizedNonUnique: Bool {
      bits & (0x1 << 7) != 0
    }
    
    public var numConditionalRequirements: Int {
      Int(bits & (0xFF << 8)) >> 8
    }
    
    public var typeReferenceKind: TypeReferenceKind {
      TypeReferenceKind(rawValue: UInt16(bits & (0x7 << 3)) >> 3)!
    }
  }
}
