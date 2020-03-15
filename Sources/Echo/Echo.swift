//
//  Echo.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// The main entry point to grab type metadata from some metatype.
/// - Parameter type: Metatype to get metadata from.
/// - Returns: Metadata for the given type.
public func reflect(_ type: Any.Type) -> Metadata {
  let ptr = unsafeBitCast(type, to: UnsafeRawPointer.self)
  
  return getMetadata(at: ptr)
}

/// The main entry point to grab type metadata from some instance.
/// - Parameter instance: Any instance value to get metadata from.
/// - Returns: Metadata for the given instance type.
public func reflect(_ instance: Any) -> Metadata {
  container(for: instance).metadata
}

public func container(for instance: Any) -> AnyExistentialContainer {
  unsafeBitCast(instance, to: AnyExistentialContainer.self)
}
