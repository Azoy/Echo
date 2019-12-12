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
  public var type: Any.Type
  
  public var metadata: Metadata {
    reflect(type)
  }
  
  public init(type: Any.Type) {
    self.type = type
  }
  
  public init(metadata: Metadata) {
    self.type = metadata.type
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
      UnsafePointer<UnsafePointer<HeapObject>>($0).pointee.raw
    }
    
    return bytePtr + Int(byteOffset)
  }
}
