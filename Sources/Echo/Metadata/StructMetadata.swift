//
//  StructMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a `struct` type in Swift.
public struct StructMetadata: TypeMetadata, LayoutWrapper {
  typealias Layout = _StructMetadata
  
  /// Backing struct metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The struct context descriptor that describes this struct.
  public var descriptor: StructDescriptor {
    StructDescriptor(ptr: layout._descriptor.signed)
  }
  
  /// An array of field offsets for this struct's stored representation.
  public var fieldOffsets: [Int] {
    let start = ptr.offset(of: descriptor.fieldOffsetVectorOffset)
    
    return Array(unsafeUninitializedCapacity: descriptor.numFields) {
      for i in 0 ..< descriptor.numFields {
        let offset = start.load(
          fromByteOffset: i * MemoryLayout<UInt32>.size,
          as: UInt32.self
        )
        
        $0[i] = Int(offset)
      }
      
      $1 = descriptor.numFields
    }
  }
}

struct _StructMetadata {
  let _kind: Int
  let _descriptor: SignedPointer<StructDescriptor>
}
