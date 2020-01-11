//
//  ContextDescriptorValues.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

extension AnonymousDescriptor {
  /// The specific flags that describe an anonymous descriptor.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt16
    
    /// Whether or not this anonymous descriptor has a trailing mangled name
    /// to debug the context.
    public var hasMangledName: Bool {
      bits & 0x1 != 0
    }
  }
}

/// A discriminator to determine what type of context a descriptor is.
public enum ContextDescriptorKind: Int {
  case module = 0
  case `extension` = 1
  case anonymous = 2
  case `protocol` = 3
  case opaqueType = 4
  case `class` = 16
  case `struct` = 17
  case `enum` = 18
}

/// The flags which describe a context descriptor.
public struct ContextDescriptorFlags {
  /// Flags as represented in bits.
  public let bits: UInt32
  
  /// The kind of context this descriptor is.
  public var kind: ContextDescriptorKind {
    return ContextDescriptorKind(rawValue: Int(bits) & 0x1F)!
  }
  
  /// I'm not really sure what unique means.
  public var isUnique: Bool {
    bits & 0x40 != 0
  }
  
  /// Whether or not this context is generic and has a generic context.
  public var isGeneric: Bool {
    bits & 0x80 != 0
  }
  
  /// The version number for this context descriptor.
  public var version: UInt8 {
    UInt8((bits >> 0x8) & 0xFF)
  }
  
  var kindSpecificFlags: UInt16 {
    UInt16((bits >> 0x10) & 0xFFFF)
  }
}

extension FieldDescriptor {
  /// A discriminator to determine what type of context this field descriptor
  /// is describing.
  public enum Kind: UInt16 {
    case `struct` = 0
    case `class` = 1
    case `enum` = 2
    case multiPayloadEnum = 3
    case `protocol` = 4
    case classProtocol = 5
    case objcProtocol = 6
    case objcClass = 7
  }
}

extension FieldRecord {
  /// The flags which describe a field record.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// Whether this is an enum case that's also `indirect`
    public var isIndirectCase: Bool {
      bits & 0x1 != 0
    }
    
    /// Whether this is a stored property that is `var`
    public var isVar: Bool {
      bits & 0x2 != 0
    }
  }
}

/// A discriminator to determine what type of parameter a generic parameter is.
public enum GenericParameterKind: UInt8 {
  case type = 0x0
}

public struct GenericParameterDescriptor {
  public let bits: UInt8
  
  public var kind: GenericParameterKind {
    GenericParameterKind(rawValue: bits & 0x3F)!
  }
  
  public var hasExtraArgument: Bool {
    bits & 0x40 != 0
  }
  
  public var hasKeyArgument: Bool {
    bits & 0x80 != 0
  }
}

/// A discriminator to determine what kind of requirement a generic requirement
/// is.
public enum GenericRequirementKind: UInt8 {
  case `protocol` = 0x0
  case sameType = 0x1
  case baseClass = 0x2
  case sameConformance = 0x3
  case layout = 0x1F
}

extension GenericRequirementDescriptor {
  public struct Flags {
    public let bits: UInt32
    
    public var kind: GenericRequirementKind {
      GenericRequirementKind(rawValue: UInt8(bits & 0x1F))!
    }
    
    public var hasExtraArgument: Bool {
      bits & 0x40 != 0
    }
    
    public var hasKeyArgument: Bool {
      bits & 0x80 != 0
    }
  }
}

/// A discriminator to determine what layout a layout requirement has.
public enum GenericRequirementLayoutKind: UInt32 {
  case `class` = 0
}

extension ProtocolDescriptor {
  public struct Flags {
    public let bits: UInt16
    
    public var hasClassConstraint: Bool {
      bits & 0x1 != 0
    }
    
    public var isResilient: Bool {
      bits & 0x2 != 0
    }
    
    public var specialProtocol: SpecialProtocol {
      SpecialProtocol(rawValue: UInt8(bits & 0xFC))!
    }
  }
}

/// The flags which describe a type's context descriptor.
public struct TypeContextDescriptorFlags {
  /// Flags as represetned in bits.
  public let bits: UInt64
  
  public var metadataInitKind: MetadataInitializationKind {
    MetadataInitializationKind(rawValue: UInt16(bits) & 0x3)!
  }
  
  public var hasImportInfo: Bool {
    bits & 0x4 != 0
  }
  
  public var resilientSuperclassRefKind: TypeReferenceKind {
    TypeReferenceKind(rawValue: UInt16(bits) & 0xE00)!
  }
  
  public var classAreImmediateMembersNegative: Bool {
    bits & 0x1000 != 0
  }
  
  public var classHasResilientSuperclass: Bool {
    bits & 0x2000 != 0
  }
  
  public var classHasOverrideTable: Bool {
    bits & 0x4000 != 0
  }
  
  /// Whether or not this class has a vtable.
  public var classHasVTable: Bool {
    bits & 0x8000 != 0
  }
}

public enum MetadataInitializationKind: UInt16 {
  case none = 0
  case singleton = 1
  case foreign = 2
}

/// The type of reference this is to some type.
public enum TypeReferenceKind: UInt16 {
  /// This is a direct relative reference to the type's context descriptor.
  case directTypeDescriptor = 0x0
  
  /// This is an indirect relative reference to the type's context descriptor.
  case indirectTypeDescriptor = 0x1
  
  /// This is a direct relative reference to some Objective-C class metadata.
  case directObjCClass = 0x2
  
  /// This is an indirect relative reference to some Objective-C class metadata.
  case indirectObjCClass = 0x3
}
