//
//  StoredProperty.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

// TODO: Document the following extension to MemoryLayout

import Echo

extension MemoryLayout {
  public struct StoredProperty {
    public let name: String
    public let type: Any.Type
    public let referenceStorage: ReferenceStorageKind
  }
}

extension MemoryLayout {
  public static var storedProperties: [StoredProperty] {
    guard let metadata = reflect(T.self) as? TypeMetadata,
          metadata.kind == .struct || metadata.kind == .class else {
      return []
    }
    
    return metadata.contextDescriptor.fields.records.map {
      return StoredProperty(
        name: $0.name,
        type: metadata.type(of: $0.mangledTypeName)!,
        referenceStorage: $0.referenceStorage
      )
    }
  }
}
