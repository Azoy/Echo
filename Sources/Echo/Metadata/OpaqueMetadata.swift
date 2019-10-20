//
//  OpaqueMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct OpaqueMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  public var kind: MetadataKind {
    .opaque
  }
}
