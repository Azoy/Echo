//
//  ClassMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import Foundation

public struct ClassMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  var _class: _ClassMetadata {
    ptr.load(as: _ClassMetadata.self)
  }
  
  public var kind: MetadataKind {
    .class
  }
  
  public var isaPointer: UnsafeRawPointer? {
    let int = ptr.load(as: Int.self)
    guard int != 0 else {
      return nil
    }
    
    return UnsafeRawPointer(bitPattern: int)!
  }
  
  public var superclassMetadata: ClassMetadata? {
    guard _class._superclassMetadata != nil else {
      return nil
    }
    
    return ClassMetadata(ptr: _class._superclassMetadata!)
  }
  
  public var superclassType: Any.Type? {
    superclassMetadata?.type
  }
  
  public var classFlags: ClassFlags {
    _class._flags
  }
  
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
    
    return _class._rodata & mask != 0
  }
  
  public var descriptor: ClassDescriptor {
    ClassDescriptor(ptr: _class._descriptor)
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

public struct ClassFlags {
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

struct _ClassMetadata {
  let _kind: Int
  let _superclassMetadata: UnsafeRawPointer?
  let _reserved: (Int, Int)
  let _rodata: Int
  let _flags: ClassFlags
  let _instanceAddressPoint: UInt32
  let _instanceSize: UInt32
  let _instanceAlignMask: UInt16
  let _runtimeReserved: UInt16
  let _classSize: UInt32
  let _classAddressPoint: UInt32
  let _descriptor: UnsafeRawPointer
}
