//
//  ClassDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// A class descriptor that descibes some class context.
public struct ClassDescriptor: TypeContextDescriptor, LayoutWrapper {
  typealias Layout = _ClassDescriptor
  
  /// Backing context descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The mangled type name for this class's superclass, if it has one.
  public var superclass: UnsafePointer<CChar> {
    address(for: \._superclass)
  }
  
  /// The negative size of the metadata objects in this class.
  public var negativeSize: Int {
    assert(!typeFlags.classHasResilientSuperclass)
    return Int(layout._negativeSizeOrResilientBounds)
  }
  
  /// The resilient bounds for this class.
  var resilientBounds: _StoredClassMetadataBounds {
    address(for: \._negativeSizeOrResilientBounds).raw
      .relativeDirectAddress(as: _StoredClassMetadataBounds.self).pointee
  }
  
  /// The positive size of the metadata objects in this class.
  public var positiveSize: Int {
    assert(!typeFlags.classHasResilientSuperclass)
    return Int(layout._positiveSizeOrExtraFlags)
  }
  
  /// The number of members this class defines. This is both properties and
  /// methods.
  public var numMembers: Int {
    Int(layout._numImmediateMembers)
  }
  
  /// The number of properties this class declares (not including superclass)
  /// properties).
  public var numFields: Int {
    Int(layout._numFields)
  }
  
  /// The number of words away the field offset vector is from canonical
  /// metadata pointer.
  public var fieldOffsetVectorOffset: Int {
    guard typeFlags.classHasResilientSuperclass else {
      return Int(layout._fieldOffsetVectorOffset)
    }
    
    return resilientBounds._immediateMembersOffset / MemoryLayout<Int>.size
            + Int(layout._fieldOffsetVectorOffset)
  }
  
  /// A pointer to the resilient superclass. This pointer differs in type
  /// depending on what typeFlags.resilientSuperclassRefKind returns.
  public var resilientSuperclass: UnsafeRawPointer? {
    guard typeFlags.classHasResilientSuperclass else {
      return nil
    }
    
    var offset = 0
    
    if flags.isGeneric {
      offset += typeGenericContext.size
    }
    
    return (trailing + offset).relativeDirectAddress(as: Void.self).raw
  }
  
  /// The foreign metadata initialization info for this class metadata, if it
  /// has any.
  public var foreignMetadataInitialization: ForeignMetadataInitialization? {
    guard typeFlags.metadataInitKind == .foreign else {
      return nil
    }
    
    var offset = 0
    
    if flags.isGeneric {
      offset += typeGenericContext.size
    }
    
    if typeFlags.classHasResilientSuperclass {
      offset += MemoryLayout<RelativeDirectPointer<Void>>.size
    }
    
    return ForeignMetadataInitialization(ptr: trailing + offset)
  }
  
  /// The singleton metadata initialization info for this class metadata, if it
  /// has any.
  public var singletonMetadataInitialization: SingletonMetadataInitialization? {
    guard typeFlags.metadataInitKind == .singleton else {
      return nil
    }
    
    var offset = 0
    
    if flags.isGeneric {
      offset += typeGenericContext.size
    }
    
    if typeFlags.classHasResilientSuperclass {
      offset += MemoryLayout<RelativeDirectPointer<Void>>.size
    }
    
    return SingletonMetadataInitialization(ptr: trailing + offset)
  }
  
  /// The VTable header information for this class, if it has a vtable.
  public var vtableHeader: VTableDescriptorHeader? {
    guard typeFlags.classHasVTable else {
      return nil
    }
    
    var offset = 0
    
    if flags.isGeneric {
      offset += typeGenericContext.size
    }
    
    if typeFlags.classHasResilientSuperclass {
      offset += MemoryLayout<RelativeDirectPointer<Void>>.size
    }
    
    if typeFlags.metadataInitKind == .foreign {
      offset += MemoryLayout<_ForeignMetadataInitialization>.size
    }
    
    if typeFlags.metadataInitKind == .singleton {
      offset += MemoryLayout<_SingletonMetadataInitialization>.size
    }
    
    return VTableDescriptorHeader(ptr: trailing + offset)
  }
  
  /// An array of all of the method descriptors for this class for the entries
  /// in the vtable, if this class has a vtable.
  public var methodDescriptors: [MethodDescriptor] {
    var result = [MethodDescriptor]()
    
    guard typeFlags.classHasVTable else {
      return result
    }
    
    let start = vtableHeader!.trailing
    
    for i in 0 ..< vtableHeader!.size {
      let address = start + i * MemoryLayout<_MethodDescriptor>.size
      result.append(MethodDescriptor(ptr: address))
    }
    
    return result
  }
  
  /// The override table header indicating how many method overrides there are
  /// for this class, if it has an override table.
  public var overrideTableHeader: OverrideTableHeader? {
    guard typeFlags.classHasOverrideTable else {
      return nil
    }
    
    var offset = 0
    
    if flags.isGeneric {
      offset += typeGenericContext.size
    }
    
    if typeFlags.metadataInitKind == .foreign {
      offset += MemoryLayout<_ForeignMetadataInitialization>.size
    }
    
    if typeFlags.metadataInitKind == .singleton {
      offset += MemoryLayout<_SingletonMetadataInitialization>.size
    }
    
    if typeFlags.classHasVTable {
      offset += MemoryLayout<_VTableDescriptorHeader>.size
      
      offset += MemoryLayout<_MethodDescriptor>.size * vtableHeader!.size
    }
    
    return OverrideTableHeader(ptr: trailing + offset)
  }
  
  /// An array of all of the method override descriptors, if this class has an
  /// override table.
  public var methodOverrideDescriptors: [MethodOverrideDescriptor] {
    var result = [MethodOverrideDescriptor]()
    
    guard typeFlags.classHasOverrideTable else {
      return result
    }
    
    let start = overrideTableHeader!.trailing
    
    for i in 0 ..< overrideTableHeader!.numEntries {
      let address = start + i * MemoryLayout<_MethodOverrideDescriptor>.size
      result.append(MethodOverrideDescriptor(ptr: address))
    }
    
    return result
  }
}

/// Structure that helps in determining where the vtable for a class is within
/// the type metadata and how many vtable entries there are.
public struct VTableDescriptorHeader: LayoutWrapper {
  typealias Layout = _VTableDescriptorHeader
  
  /// Backing VTableDescriptorHeader pointer.
  let ptr: UnsafeRawPointer
  
  /// The offset to the vtable from the class metadata.
  public var offset: Int {
    Int(layout._offset)
  }
  
  /// The number of vtable methods.
  public var size: Int {
    Int(layout._size)
  }
}

/// Structure that describes a class or protocol method.
public struct MethodDescriptor: LayoutWrapper {
  typealias Layout = _MethodDescriptor
  
  /// Backing MethodDescriptor pointer.
  let ptr: UnsafeRawPointer
  
  /// Flags that describe this method descriptor.
  public var flags: Flags {
    layout._flags
  }
}

/// Structure that tells the number of method override entries in a class
/// descriptor.
public struct OverrideTableHeader: LayoutWrapper {
  typealias Layout = _OverrideTableHeader
  
  /// Backing OverrideTableHeader pointer.
  let ptr: UnsafeRawPointer
  
  /// The number of override method entries.
  public var numEntries: Int {
    Int(layout._numEntries)
  }
}

/// A method override descriptor describes the method being overriden from what
/// class.
public struct MethodOverrideDescriptor: LayoutWrapper {
  typealias Layout = _MethodOverrideDescriptor
  
  /// Backing MethodOverrideDescriptor pointer.
  let ptr: UnsafeRawPointer
  
  /// The class containing the base method.
  public var `class`: ContextDescriptor {
    getContextDescriptor(at: address(for: \._class))
  }
  
  /// The base method descriptor.
  public var method: MethodDescriptor {
    MethodDescriptor(ptr: address(for: \._method))
  }
}

/// Bounds for metadata objects.
public struct MetadataBounds {
  let _negativeSize: UInt32
  let _positiveSize: UInt32
  
  /// The negative size of the metadata in words.
  public var negativeSize: Int {
    Int(_negativeSize)
  }
  
  /// The positive size of the metadata in words.
  public var positiveSize: Int {
    Int(_positiveSize)
  }
}

struct _ClassDescriptor {
  let _base: _TypeDescriptor
  let _superclass: RelativeDirectPointer<CChar>
  
  // This is either a uint32 for negative size, or a relative direct pointer
  // to class metadata bounds if the superclass is resilient.
  let _negativeSizeOrResilientBounds: UInt32
  
  // This is either a uint32 for positive size, or extra class flags
  // if the superclass is resilient.
  let _positiveSizeOrExtraFlags: UInt32
  
  let _numImmediateMembers: UInt32
  let _numFields: UInt32
  let _fieldOffsetVectorOffset: UInt32
}

struct _StoredClassMetadataBounds {
  let _immediateMembersOffset: Int
  let _bounds: MetadataBounds
}

struct _VTableDescriptorHeader {
  let _offset: UInt32
  let _size: UInt32
}

struct _MethodDescriptor {
  let _flags: MethodDescriptor.Flags
  let _impl: RelativeDirectPointer<Void>
}

struct _OverrideTableHeader {
  let _numEntries: UInt32
}

struct _MethodOverrideDescriptor {
  let _class: RelativeIndirectablePointer<_ContextDescriptor>
  let _method: RelativeIndirectablePointer<_MethodDescriptor>
  let _impl: RelativeDirectPointer<Void>
}
