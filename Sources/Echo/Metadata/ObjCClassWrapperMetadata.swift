//
//  ObjCClassWrapperMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents an Objective-C class that wasn't
/// Swift compiled.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct ObjCClassWrapperMetadata: Metadata, LayoutWrapper {
  typealias Layout = _ObjCClassWrapperMetadata
  
  /// Backing Objective-C class wrapper metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The class type that this wrapper houses.
  public var classType: Any.Type {
    layout._classMetadata
  }
  
  /// The class metadata.
  public var classMetadata: ClassMetadata {
    reflectClass(classType)!
  }
  
  /// The list of conformances defined for this type metadata.
  ///
  /// NOTE: This list is populated once before the program starts with all of
  ///       the conformances that are statically know at compile time. If you
  ///       are attempting to load libraries dynamically at runtime, this list
  ///       will update automatically, so make sure if you need up to date
  ///       information on a type's conformances, fetch this often. Example:
  ///
  ///       let metadata = ...
  ///       var conformances = metadata.conformances
  ///       loadPlugin(...)
  ///       // conformances is now outdated! Refresh it by calling this again.
  ///       conformances = metadata.conformances
  public var conformances: [ConformanceDescriptor] {
    conformanceLock.withLock {
      Echo.conformances[ptr, default: []]
    }
  }
}

extension ObjCClassWrapperMetadata: Equatable {}

struct _ObjCClassWrapperMetadata {
  let _kind: Int
  let _classMetadata: Any.Type
}
