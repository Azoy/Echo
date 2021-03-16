//
//  ClassDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

import Atomics

#if canImport(ObjectiveC)
import ObjectiveC
import CEcho
#endif

/// A class descriptor that descibes some class context.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct ClassDescriptor: TypeContextDescriptor, LayoutWrapper {
  typealias Layout = _ClassDescriptor
  
  /// Backing context descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The mangled type name for this class's superclass, if it has one.
  public var superclass: UnsafeRawPointer {
    address(for: \._superclass)
  }
  
  /// The negative size of the metadata objects in this class.
  public var negativeSize: Int {
    assert(!typeFlags.classHasResilientSuperclass)
    return Int(layout._negativeSizeOrResilientBounds)
  }
  
  /// The resilient bounds for this class.
  var resilientBounds: StoredClassMetadataBounds {
    let start = address(for: \._negativeSizeOrResilientBounds)
    let address = start.relativeDirectAddress(
      as: _StoredClassMetadataBounds.self
    )
    return StoredClassMetadataBounds(ptr: address)
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
    
    // Load the immediate members offset as seq_cst. I'm unsure if this is the
    // correct memory order that was intended, but currently in Metadata.h in
    // the Swift repository there is an implicit one used in
    // `getFieldOffsetVectorOffset`. There is no explicit memory order load, so
    // by default C++ chooses seq_cst for arithmetic operations. Be consistent
    // with what the Swift runtime is currently doing.
    
    // The memory is already initialized from the binary, here we're simply
    // binding the type from Swift's perspective. AFAICT, there is no way to
    // just unbind a type from memory without deinitializing it as well (which
    // we don't want to do).
    let atomicIntPtr = resilientBounds.ptr.mutable.bindMemory(
      to: Int.AtomicRepresentation.self,
      capacity: 1
    )
    
    let immediateMembersOffset = Int.AtomicRepresentation.atomicLoad(
      at: atomicIntPtr,
      ordering: .sequentiallyConsistent
    )
    
    return immediateMembersOffset / MemoryLayout<Int>.size
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
    
    return (trailing + offset).relativeDirectAddress(as: Void.self)
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
    guard typeFlags.classHasVTable else {
      return []
    }
    
    return Array(unsafeUninitializedCapacity: vtableHeader!.size) {
      let start = vtableHeader!.trailing
      
      for i in 0 ..< vtableHeader!.size {
        let address = start.offset(of: i, as: _MethodDescriptor.self)
        $0[i] = MethodDescriptor(ptr: address)
      }
      
      $1 = vtableHeader!.size
    }
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
    guard typeFlags.classHasOverrideTable else {
      return []
    }
    
    return Array(unsafeUninitializedCapacity: overrideTableHeader!.numEntries) {
      let start = overrideTableHeader!.trailing
      
      for i in 0 ..< overrideTableHeader!.numEntries {
        let address = start.offset(of: i, as: _MethodOverrideDescriptor.self)
        $0[i] = MethodOverrideDescriptor(ptr: address)
      }
      
      $1 = overrideTableHeader!.numEntries
    }
  }
  
  // Internal methods related to Metadata bounds and argument offsets.
  
  var genericArgumentOffset: Int {
    if typeFlags.classHasResilientSuperclass {
      return resilientImmediateMembersOffset
    } else {
      return nonResilientImmediateMembersOffset
    }
  }
  
  var nonResilientImmediateMembersOffset: Int {
    assert(!typeFlags.classHasResilientSuperclass)
    
    if typeFlags.classAreImmediateMembersNegative {
      return -negativeSize
    } else {
      return positiveSize - numMembers
    }
  }
  
  var metadataBoundsForSwiftClass: (Int, Int, Int) {
    let immediateMemberOffset = MemoryLayout<_ClassMetadata>.size
    let positiveSize = MemoryLayout<_ClassMetadata>.size / MemoryLayout<Int>.size
    // This is the class metadata header size, which is the destructor pointer
    // + the value witness table pointer = 16 bytes.
    // 16 bytes / sizeof(void *) = 2
    let negativeSize = 2
    
    return (immediateMemberOffset, positiveSize, negativeSize)
  }
  
  var resilientImmediateMembersOffset: Int {
    assert(typeFlags.classHasResilientSuperclass)
    
    let immediateMembersOffset = resilientBounds.immediateMembersOffset
    
    // If this value is already cached, use it.
    if immediateMembersOffset != 0 {
      return immediateMembersOffset / MemoryLayout<Int>.size
    }
    
    // Otherwise, we're going to need to compute it.
    var immediateMemberOffset = 0
    var positiveSize = 0
    var negativeSize = 0
    
    if let superclass = resilientSuperclass {
      
      func getMetadataBoundsForObjCClass(_ cls: AnyClass) -> (Int, Int, Int) {
        let metadata = reflectClass(cls)!
        
        let rootBounds = metadataBoundsForSwiftClass
        // 0 = Immediate member offset, 1 = positive size, 2 = negative size
        var bounds = (0, 0, 0)
        
        if !metadata.isSwiftClass {
          return rootBounds
        }
        
        bounds.0 = metadata.classSize - metadata.classAddressPoint
        bounds.1 = (metadata.classSize - metadata.classAddressPoint) / MemoryLayout<Int>.size
        bounds.2 = metadata.classAddressPoint / MemoryLayout<Int>.size
        
        if bounds.2 < rootBounds.2 {
          bounds.2 = rootBounds.2
        }
        
        if bounds.1 < rootBounds.1 {
          bounds.1 = rootBounds.1
        }
        
        return bounds
      }
      
      switch typeFlags.resilientSuperclassRefKind {
      case .indirectTypeDescriptor:
        let descriptor = ClassDescriptor(
          ptr: superclass.load(as: SignedPointer<ClassDescriptor>.self).signed
        )
        immediateMemberOffset = descriptor.genericArgumentOffset
        
      case .directTypeDescriptor:
        let descriptor = ClassDescriptor(ptr: superclass)
        immediateMemberOffset = descriptor.genericArgumentOffset
        
      case .directObjCClass:
        #if canImport(ObjectiveC)
        let name = UnsafePointer<CChar>(superclass._rawValue)
        guard var cls = objc_lookUpClass(name) else {
          let name = String(cString: name)
          fatalError("Failed to lookup Objective-C class named: \(name)")
        }
        
        cls = swift_getInitializedObjCClass(cls)
        (immediateMemberOffset, positiveSize, negativeSize) =
          getMetadataBoundsForObjCClass(cls)
        #else
        break
        #endif
        
      case .indirectObjCClass:
        #if canImport(ObjectiveC)
        let cls = UnsafePointer<AnyClass>(superclass._rawValue)
        (immediateMemberOffset, positiveSize, negativeSize) =
          getMetadataBoundsForObjCClass(cls.pointee)
        #else
        break
        #endif
      }
    } else {
      (immediateMemberOffset, positiveSize, negativeSize) =
        metadataBoundsForSwiftClass
    }
    
    if typeFlags.classAreImmediateMembersNegative {
      negativeSize += numMembers
      immediateMemberOffset = -negativeSize * MemoryLayout<Int>.size
    } else {
      immediateMemberOffset = positiveSize * MemoryLayout<Int>.size
      positiveSize += numMembers
    }
    
    let start = address(for: \._negativeSizeOrResilientBounds)
    let bounds = UnsafeMutablePointer(mutating: start.relativeDirectAddress(
      as: _StoredClassMetadataBounds.self
    ).assumingMemoryBound(to: _StoredClassMetadataBounds.self))
    
    bounds.pointee._bounds._positiveSize = UInt32(positiveSize)
    bounds.pointee._bounds._negativeSize = UInt32(negativeSize)
    
    bounds.withMemoryRebound(to: Int.AtomicRepresentation.self, capacity: 1) {
      Int.AtomicRepresentation.atomicStore(
        immediateMemberOffset,
        at: $0,
        ordering: .releasing
      )
    }
    
    return immediateMemberOffset / MemoryLayout<Int>.size
  }
}

extension ClassDescriptor: Equatable {}

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
  var _negativeSize: UInt32
  var _positiveSize: UInt32
  
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
  var _immediateMembersOffset: Int.AtomicRepresentation
  var _bounds: MetadataBounds
}

struct StoredClassMetadataBounds: LayoutWrapper {
  typealias Layout = _StoredClassMetadataBounds
  
  let ptr: UnsafeRawPointer
  
  var immediateMembersOffset: Int {
    Int.AtomicRepresentation.atomicLoad(
      at: ptr.mutable.bindMemory(to: Int.AtomicRepresentation.self, capacity: 1),
      ordering: .relaxed
    )
  }
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
