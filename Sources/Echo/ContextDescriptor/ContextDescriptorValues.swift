//
//  ContextDescriptorValues.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
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
  
  /// Whether this context is "unique".
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

extension GenericMetadataPattern {
  /// Flags that describe this generic metadata pattern.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// Whether or not this metadata pattern has an extra pattern.
    public var hasExtraDataPattern: Bool {
      bits & 0x1 != 0
    }
    
    /// Whether or not the metadata of this pattern have trailing flags.
    public var hasTrailingFlags: Bool {
      bits & 0x2 != 0
    }
    
    /// The kind of metadata this value metadata pattern is.
    public var valueMetadataKind: MetadataKind {
      return MetadataKind(rawValue: Int(bits >> 21))!
    }
    
    /// Whether or not this class pattern has an immediate member pattern.
    public var classHasImmediateMembersPattern: Bool {
      bits & (0x1 << 30) != 0
    }
  }
}

/// A discriminator to determine what type of parameter a generic parameter is.
public enum GenericParameterKind: UInt8 {
  case type = 0x0
}

/// The flags that describe a generic parameter.
public struct GenericParameterDescriptor {
  /// Flags as represented in bits.
  public let bits: UInt8
  
  /// The kind of generic parameter this is.
  public var kind: GenericParameterKind {
    GenericParameterKind(rawValue: bits & 0x3F)!
  }
  
  /// Unsure what this means, it's always false for the time being.
  public var hasExtraArgument: Bool {
    bits & 0x40 != 0
  }
  
  /// "Key" refers to a generic param whose metadata is provided at runtime.
  /// Non-key would mean we derive the generic parameter from elsewhere.
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
  /// The flags that describe a generic requirement.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// The kind of generic requirement this is.
    public var kind: GenericRequirementKind {
      GenericRequirementKind(rawValue: UInt8(bits & 0x1F))!
    }
    
    /// Whether this generic requirement has an "extra" argument.
    public var hasExtraArgument: Bool {
      bits & 0x40 != 0
    }
    
    /// Whether this generic requirement has a "key" argument.
    public var hasKeyArgument: Bool {
      bits & 0x80 != 0
    }
  }
}

/// A discriminator to determine what layout a layout requirement has.
public enum GenericRequirementLayoutKind: UInt32 {
  case `class` = 0
}

extension MethodDescriptor {
  /// Flags that describe a method descriptor.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// The kind of method this is.
    public var kind: Kind {
      Kind(rawValue: UInt8(bits & 0xF))!
    }
    
    /// Whether or not this method is an instance method.
    public var isInstance: Bool {
      bits & 0x10 != 0
    }
    
    /// Whether or not this method is dynamic.
    public var isDynamic: Bool {
      bits & 0x20 != 0
    }
  }
}

extension MethodDescriptor {
  /// A discriminator to indicate what kind of method a method descriptor is.
  public enum Kind: UInt8 {
    case method
    case `init`
    case getter
    case setter
    case modifyCoroutine
    case readCoroutine
  }
}

extension ProtocolDescriptor {
  /// The flags that describe a protocol descriptor.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt16
    
    /// Whether this protocol descriptor has a class constraint.
    /// E.g. AnyObject constraint.
    public var hasClassConstraint: Bool {
      bits & 0x1 != 0
    }
    
    /// Whether this protocol is built for resilience.
    public var isResilient: Bool {
      bits & 0x2 != 0
    }
    
    /// The special protocol kind this protocol is, if it is one.
    public var specialProtocol: SpecialProtocol {
      SpecialProtocol(rawValue: UInt8(bits & 0xFC))!
    }
  }
}

extension ProtocolRequirement {
  /// The flags that describe a protocol requirement.
  public struct Flags {
    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// The kind of protocol requirement this is.
    public var kind: Kind {
      Kind(rawValue: UInt8(bits & 0xF))!
    }
    
    /// Whether this protocol requirement is some instance requirement.
    public var isInstance: Bool {
      bits & 0x10 != 0
    }
  }
}

extension ProtocolRequirement {
  /// A discriminator to determine what kind of protocol requirement this is.
  public enum Kind: UInt8 {
    case baseProtocol
    case method
    case `init`
    case getter
    case setter
    case readCoroutine
    case modifyCoroutine
    case associatedTypeAccessFunction
    case associatedConformanceAccessFunction
  }
}

/// A discriminator to determine what kind of reference storage modifier a field
/// is.
public enum ReferenceStorageKind: String {
  /// A normal field declaration.
  /// E.g. let someClass: SomeClass
  case none = ""
  
  /// A weak field declaration.
  /// E.g. weak var someClass: SomeClass?
  case weak = "Xw"
  
  /// An unowned field declaration.
  /// E.g. unowned let someClass: SomeClass
  case unowned = "Xo"
  
  /// An unmanaged field declaration.
  /// E.g. unowned(unsafe) let someClass: SomeClass
  case unmanaged = "Xu"
}

/// The flags which describe a type's context descriptor.
public struct TypeContextDescriptorFlags {
  /// Flags as represetned in bits.
  public let bits: UInt64
  
  /// The metadata initialization kind, if any.
  public var metadataInitKind: MetadataInitializationKind {
    MetadataInitializationKind(rawValue: UInt16(bits) & 0x3)!
  }
  
  /// Whether this type context has any import information.
  public var hasImportInfo: Bool {
    bits & 0x4 != 0
  }
  
  /// The resilient superclass type reference kind.
  public var resilientSuperclassRefKind: TypeReferenceKind {
    TypeReferenceKind(rawValue: UInt16(bits) & 0xE00)!
  }
  
  /// Whether or not this class has any immediate members negative.
  public var classAreImmediateMembersNegative: Bool {
    bits & 0x1000 != 0
  }
  
  /// Whether or not this class has a resilient superclass.
  public var classHasResilientSuperclass: Bool {
    bits & 0x2000 != 0
  }
  
  /// Whether or not this class has an override table.
  public var classHasOverrideTable: Bool {
    bits & 0x4000 != 0
  }
  
  /// Whether or not this class has a vtable.
  public var classHasVTable: Bool {
    bits & 0x8000 != 0
  }
}

/// A discriminator to determine what kind of initialization this metadata goes
/// through, if any.
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
