//
//  TypeContextDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// A type context descriptor is a context descriptor who defines some new type.
/// This includes structs, classes, and enums. Protocols also define a new type,
/// but aren't considered type context descriptors.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public protocol TypeContextDescriptor: ContextDescriptor {
  /// The flags that describe this type context descriptor.
  var typeFlags: TypeContextDescriptorFlags { get }
  
  /// The name of this type.
  var name: String { get }
  
  /// The metadata access function.
  var accessor: MetadataAccessFunction { get }
  
  /// The field descriptor that describes the stored representation of this
  /// type.
  var fields: FieldDescriptor { get }
  
  /// If this type has foreign metadata initialization, return it.
  var foreignMetadataInitialization: ForeignMetadataInitialization? { get }
  
  /// If this type has singleton metadata initialization, return it.
  var singletonMetadataInitialization: SingletonMetadataInitialization? { get }
}

extension TypeContextDescriptor {
  var _typeDescriptor: _TypeDescriptor {
    ptr.load(as: _TypeDescriptor.self)
  }
  
  /// The flags that describe this type context descriptor.
  public var typeFlags: TypeContextDescriptorFlags {
    TypeContextDescriptorFlags(bits: UInt64(flags.kindSpecificFlags))
  }
  
  /// The name of this type.
  public var name: String {
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = _typeDescriptor._name.address(from: offset)
    return address.string
  }
  
  /// The metadata access function.
  public var accessor: MetadataAccessFunction {
    let offset = ptr.offset(of: 3, as: Int32.self)
    let accessor = _typeDescriptor._accessor.address(from: offset)
    return MetadataAccessFunction(ptr: accessor)
  }
  
  /// Whether or not this type has a field descriptor.
  public var isReflectable: Bool {
    _typeDescriptor._fields.offset != 0
  }
  
  /// The field descriptor that describes the stored representation of this
  /// type.
  public var fields: FieldDescriptor {
    let offset = ptr.offset(of: 4, as: Int32.self)
    let address = _typeDescriptor._fields.address(from: offset)
    return FieldDescriptor(ptr: address)
  }
  
  /// The generic context that is unique to type context descriptors.
  public var typeGenericContext: TypeGenericContext {
    TypeGenericContext(ptr: ptr + genericContextOffset)
  }
}

/// Structure that contains the completion function for initializing singleton
/// foreign metadata.
public struct ForeignMetadataInitialization: LayoutWrapper {
  typealias Layout = _ForeignMetadataInitialization
  
  /// Backing ForeignMetadataInitialzation pointer.
  let ptr: UnsafeRawPointer
}

/// Structure that contains information needed to perform initialization of
/// singleton value metadata.
public struct SingletonMetadataInitialization: LayoutWrapper {
  typealias Layout = _SingletonMetadataInitialization
  
  /// Backing SingletonMetadataInitialization pointer.
  let ptr: UnsafeRawPointer
}

struct _TypeDescriptor {
  let _base: _ContextDescriptor
  let _name: RelativeDirectPointer<CChar>
  let _accessor: RelativeDirectPointer<UnsafeRawPointer>
  let _fields: RelativeDirectPointer<_FieldDescriptor>
}

struct _ForeignMetadataInitialization {
  let _completionFunc: RelativeDirectPointer<UnsafeRawPointer>
}

struct _SingletonMetadataInitialization {
  let _initializationCache: RelativeDirectPointer<Void>
  
  // This is either a relative direct pointer to some incomplete metadata, or
  // a relative direct pointer to some resilent class metadata pattern.
  let _incompleteMetadataOrResilientPattern: Int32
  
  let _completionFunc: RelativeDirectPointer<UnsafeRawPointer>
}
