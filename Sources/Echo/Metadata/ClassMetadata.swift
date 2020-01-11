//
//  ClassMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct ClassMetadata: TypeMetadata, LayoutWrapper {
  typealias Layout = _ClassMetadata
  
  public let ptr: UnsafeRawPointer
  
  public var descriptor: ClassDescriptor {
    layout._descriptor
  }
  
  public var isaPointer: UnsafeRawPointer? {
    let int = ptr.load(as: Int.self)
    guard int != 0 else {
      return nil
    }
    
    return UnsafeRawPointer(bitPattern: int)!
  }
  
  public var superclassType: Any.Type? {
    layout._superclass
  }
  
  public var superclassMetadata: ClassMetadata? {
    superclassType.map { reflect($0) as! ClassMetadata }
  }
  
  public var classFlags: Flags {
    layout._flags
  }
  
  // FIXME: This isn't quite right yet...
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
    
    return layout._rodata & mask != 0
  }
  
  public var fieldOffsets: [Int] {
    let start = ptr.offset(of: descriptor.fieldOffsetVectorOffset)
    let buffer = UnsafeBufferPointer<UInt32>(
      start: UnsafePointer<UInt32>(start),
      count: descriptor.numFields
    )
    return Array(buffer).map { Int($0) }
  }
}

struct _ClassMetadata {
  let _kind: Int
  let _superclass: Any.Type?
  let _reserved: (Int, Int)
  let _rodata: Int
  let _flags: ClassMetadata.Flags
  let _instanceAddressPoint: UInt32
  let _instanceSize: UInt32
  let _instanceAlignMask: UInt16
  let _runtimeReserved: UInt16
  let _classSize: UInt32
  let _classAddressPoint: UInt32
  let _descriptor: ClassDescriptor
}
