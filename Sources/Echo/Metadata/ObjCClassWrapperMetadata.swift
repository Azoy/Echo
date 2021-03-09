//
//  ObjCClassWrapperMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents an Objective-C class that wasn't
/// Swift compiled.
public struct ObjCClassWrapperMetadata: Metadata, LayoutWrapper {
  typealias Layout = _ObjCClassWrapperMetadata
  
  /// Backing Objective-C class wrapper metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The class type that this wrapper houses.
  public var classType: Any.Type {
    layout._classMetadata
  }
  
  /// The class metadata 
  public var classMetadata: ClassMetadata {
    reflectClass(classType)!
  }
  
  public var conformances: [ConformanceDescriptor] {
    Echo.conformances[ptr, default: []]
  }
}

extension ObjCClassWrapperMetadata: Equatable {}

struct _ObjCClassWrapperMetadata {
  let _kind: Int
  let _classMetadata: Any.Type
}
