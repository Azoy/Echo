//
//  ExistentialContainer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

// typealias Any = AnyExistentialContainer :)

/// An any existential container holds the necessary information for any value
/// with type Any. I.e. the type erased type.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct AnyExistentialContainer {
  /// The storage needed to house the value of said type. This can be stored
  /// inline with all the data necessary to represent said type in 3 words, or
  /// could be stored indirectly through some pointer hoops. It's best to
  /// access the value through `projectValue`.
  public var data: (Int, Int, Int) = (0, 0, 0)
  
  /// The type being stored.
  public var type: Any.Type
  
  /// The metadata for the type being stored.
  public var metadata: Metadata {
    reflect(type)
  }
  
  /// Initializes an existential container.
  /// - Parameter type: The type to create an existential container for.
  public init(type: Any.Type) {
    self.type = type
  }
  
  /// Initializes an existential container.
  /// - Parameter metadata: The metadata for the type to create an existential
  ///                       container for.
  public init(metadata: Metadata) {
    self.type = metadata.type
  }
  
  /// Accesses the value of `type` being stored in this container.
  /// - Returns: The opaque pointer to value of `type`.
  public mutating func projectValue() -> UnsafeRawPointer {
    // If the value is stored inline, just return a pointer to data.
    guard !metadata.vwt.flags.isValueInline else {
      return withUnsafePointer(to: &self) {
        $0.raw
      }
    }
    
    // Otherwise, we need to go through some hoops to access the pointer.
    let alignMask = UInt(metadata.vwt.flags.alignmentMask)
    let heapObjSize = UInt(MemoryLayout<HeapObject>.size)
    let byteOffset = (heapObjSize + alignMask) & ~alignMask
    let bytePtr = withUnsafePointer(to: &self) {
      $0.withMemoryRebound(to: UnsafePointer<HeapObject>.self, capacity: 1) {
        $0.pointee.raw
      }
    }
    
    return bytePtr + Int(byteOffset)
  }
}

/// An existential container is a type in Swift that contains some struct or
/// class with information of what the type it's containing is, and the witness
/// tables needed that the existential (protocol) is.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct ExistentialContainer {
  /// The base any existential, also known as Any.
  public var base: AnyExistentialContainer
  
  /// A pointer to the witness table.
  public var witnessTable: WitnessTable
}

/// An existential container is a type in Swift that contains some struct or
/// class with information of what the type it's containing is, and the witness
/// tables needed that the existential (protocol) is. Dual supports an
/// existential that is composed of two protocols. E.g. X & Y
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct DualExistentialContainer {
  /// The base any existential, also known as Any.
  public var base: AnyExistentialContainer
  
  /// A pointer to witness tables.
  public var witnessTables: (WitnessTable, WitnessTable)
}
