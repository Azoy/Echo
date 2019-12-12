//
//  StoredProperties.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import Echo

extension MemoryLayout {
  public static var storedProperties: [StoredProperty] {
    guard let metadata = reflect(T.self) as? TypeMetadata else {
      return []
    }
    
    return metadata.contextDescriptor.fields.records.map {
      StoredProperty(
        name: $0.name,
        type: metadata.type(of: $0.mangledTypeName)!
      )
    }
  }
}

extension MemoryLayout {
  public struct StoredProperty {
    public let name: String
    public let type: Any.Type
  }
}
