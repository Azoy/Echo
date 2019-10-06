//
//  StructMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
//

public struct StructMetadata: ValueMetadata {
  
  public typealias Descriptor = StructDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var kind: MetadataKind {
    .struct
  }
  
}
