//
//  ForeignClassMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a foreign reference counted object
/// from another language that Swift observes.
public struct ForeignClassMetadata: Metadata, LayoutWrapper {
  typealias Layout = _ForeignClassMetadata
  
  /// Backing foreign class metadata pointer.
  public let ptr: UnsafeRawPointer
}

extension ForeignClassMetadata: Equatable {}

struct _ForeignClassMetadata {
  let _kind: Int
  let _descriptor: ClassDescriptor
  let _superclass: Any.Type?
}
