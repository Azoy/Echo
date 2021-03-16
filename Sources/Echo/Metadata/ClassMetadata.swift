//
//  ClassMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a `class` type in Swift.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct ClassMetadata: TypeMetadata, LayoutWrapper {
  typealias Layout = _ClassMetadata
  
  /// Backing class metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The class context descriptor that describes this class.
  public var descriptor: ClassDescriptor {
    precondition(isSwiftClass)
    return ClassDescriptor(ptr: layout._descriptor.signed)
  }
  
  /// The Objective-C ISA pointer, if it has one.
  public var isaPointer: UnsafeRawPointer? {
    let int = ptr.load(as: Int.self)
    guard int != 0 else {
      return nil
    }
    
    return UnsafeRawPointer(bitPattern: int)!
  }
  
  /// The superclass type that this class inherits from, if it inherits one at
  /// all.
  public var superclassType: Any.Type? {
    layout._superclass
  }
  
  /// The superclass type metadata that this class inherits from, it it inherits
  /// one at all.
  public var superclassMetadata: ClassMetadata? {
    superclassType.map { reflectClass($0)! }
  }
  
  /// The offset of the address point within the class.
  public var classAddressPoint: Int {
    Int(layout._classAddressPoint)
  }
  
  /// The specific flags that describe this class metadata.
  public var flags: Flags {
    layout._flags
  }
  
  /// The size of the class including headers and suffixes.
  public var classSize: Int {
    Int(layout._classSize)
  }
  
  // FIXME: Below isn't quite right yet... It doesn't take into account what's
  // on disk and what's currently being run.
  // See: https://twitter.com/slava_pestov/status/1185589328526876672
  
  /// Whether or not this class was defined in Swift.
  public var isSwiftClass: Bool {
    #if canImport(Darwin)
    // Xcode uses this and older runtimes do too
    var mask = 0x1
    
    // Swift in the OS uses 0x2
    if #available(macOS 10.14.4, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
      mask = 0x2
    }
    #else
    let mask = 0x1
    #endif
    
    return Int(bitPattern: layout._rodata) & mask != 0
  }
  
  /// The address point for instances of this type.
  public var instanceAddressPoint: Int {
    Int(layout._instanceAddressPoint)
  }
  
  /// The required size of instances of this type.
  public var instanceSize: Int {
    Int(layout._instanceSize)
  }
  
  /// The alignment mask of the address point for instances of this type.
  public var instanceAlignmentMask: Int {
    Int(layout._instanceAlignMask)
  }
  
  /// An array of field offsets for this class's stored representation.
  public var fieldOffsets: [Int] {
    Array(unsafeUninitializedCapacity: descriptor.numFields) {
      let start = ptr.offset(of: descriptor.fieldOffsetVectorOffset)
      
      for i in 0 ..< descriptor.numFields {
        let offset = start.load(
          fromByteOffset: i * MemoryLayout<Int>.size,
          as: Int.self
        )
        
        $0[i] = offset
      }
      
      $1 = descriptor.numFields
    }
  }
}

extension ClassMetadata: Equatable {}

struct _ClassMetadata {
  let _kind: Int
  let _superclass: Any.Type?
  let _reserved: (Int, Int)
  let _rodata: UnsafeRawPointer
  let _flags: ClassMetadata.Flags
  let _instanceAddressPoint: UInt32
  let _instanceSize: UInt32
  let _instanceAlignMask: UInt16
  let _runtimeReserved: UInt16
  let _classSize: UInt32
  let _classAddressPoint: UInt32
  let _descriptor: SignedPointer<ClassDescriptor>
  let _ivarDestroyer: UnsafeRawPointer
}
