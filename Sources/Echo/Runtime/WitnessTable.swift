//
//  WitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 - 2021 Alejandro Alonso. All rights reserved.
//

/// In its simpliest form, a witness table is simply a table of function pointers
/// that fulfill the requirements a protocol imposes. Witness tables instruct
/// exactly how a type conforms to a protocol and the functions needed to
/// satisy a protocol requirement.
///
/// - Note: While witness tables in the form provided are ABI stable (on some
///         platforms), its runtime layout is not ABI stable. The only ABI
///         stable portion of a witness table is the conformance descriptor
///         pointer at the beginning, the rest of the layout is completely
///         dependent on the protocol and runtime being used.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct WitnessTable: LayoutWrapper {
  typealias Layout = _WitnessTable
  
  let ptr: UnsafeRawPointer
  
  /// The conformance descriptor that describes the protocol conformance
  /// relationship for whatever type this witness table is representing, and
  /// the protocol that type conforms to.
  public var conformanceDescriptor: ConformanceDescriptor {
    layout._conformance
  }
}

struct _WitnessTable {
  let _conformance: ConformanceDescriptor
}
