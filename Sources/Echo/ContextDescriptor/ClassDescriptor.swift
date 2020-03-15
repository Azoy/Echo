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
    Int(layout._fieldOffsetVectorOffset)
  }
}

struct _StoredClassMetadataBounds {
  let _immediateMembersOffset: Int
  //let _bounds: MetadataBounds
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
