//
//  ModuleDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// A module descriptor that describes some Swift module.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct ModuleDescriptor: ContextDescriptor, LayoutWrapper {
  typealias Layout = _ModuleDescriptor
  
  /// Backing context descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// The name of the compiled Swift module.
  public var name: String {
    address(for: \._name).string
  }
}

extension ModuleDescriptor: Equatable {}

struct _ModuleDescriptor {
  let _base: _ContextDescriptor
  let _name: RelativeDirectPointer<CChar>
}
