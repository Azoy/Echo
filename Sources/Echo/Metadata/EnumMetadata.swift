//
//  EnumMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public struct EnumMetadata: ValueMetadata {
  
  public typealias Descriptor = EnumDescriptor
  
  public let ptr: UnsafeRawPointer
  
  public var kind: MetadataKind {
    .enum
  }
  
}
