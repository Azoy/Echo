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
  
  public var superclassMetadata: ClassMetadata? {
    guard superclassType != nil else {
      return nil
    }
    
    return ClassMetadata(
      ptr: unsafeBitCast(superclassType!, to: UnsafeRawPointer.self)
    )
  }
  
  public var superclassType: Any.Type? {
    layout._superclass
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
    var result = [Int]()
    
    for i in 0 ..< descriptor.numFields {
      let address = ptr.offset(of: descriptor.fieldOffsetVectorOffset + i)
      result.append(address.load(as: Int.self))
    }
    
    return result
  }
}

extension ClassMetadata {
  public struct Flags {
    public let bits: UInt32
    
    public var isSwiftPreStableABI: Bool {
      bits & 0x1 != 0
    }
    
    public var usesSwiftRefCounting: Bool {
      bits & 0x2 != 0
    }
    
    public var hasCustomObjCName: Bool {
      bits & 0x4 != 0
    }
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
