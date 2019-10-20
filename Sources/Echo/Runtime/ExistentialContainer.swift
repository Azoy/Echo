//
//  ExistentialContainer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

// typealias Any = ExistentialContainer :)
public struct ExistentialContainer {
  public var data: (Int, Int, Int) = (0, 0, 0)
  public var metadataPtr: UnsafeRawPointer
  
  public var metadata: Metadata {
    getMetadata(at: metadataPtr)
  }
  
  public var type: Any.Type {
    unsafeBitCast(metadataPtr, to: Any.Type.self)
  }
  
  public init(type: Metadata) {
    self.metadataPtr = type.ptr
  }
  
  public init(type: Any.Type) {
    self.metadataPtr = unsafeBitCast(type, to: UnsafeRawPointer.self)
  }
  
  public mutating func projectValue() -> UnsafeRawPointer {
    guard !metadata.vwt.flags.isValueInline else {
      return withUnsafePointer(to: &self) {
        $0.raw
      }
    }
    
    let alignMask = UInt(metadata.vwt.flags.alignmentMask)
    let heapObjSize = UInt(MemoryLayout<HeapObject>.size)
    let byteOffset = (heapObjSize + alignMask) & ~alignMask
    let bytePtr = withUnsafePointer(to: &self) {
      UnsafePointer<UnsafePointer<HeapObject>>($0.raw._rawValue).pointee.raw
    }
    return bytePtr.advanced(by: Int(byteOffset))
  }
}
