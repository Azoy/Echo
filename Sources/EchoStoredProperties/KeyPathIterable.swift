//
//  KeyPathIterable.swift
//  
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import Echo

public protocol KeyPathIterable {
  associatedtype AllKeyPaths: Collection
    where AllKeyPaths.Element == PartialKeyPath<Self>
  
  var allKeyPaths: AllKeyPaths { get }
}

extension KeyPathIterable {
  subscript(_ name: String) -> Any {
    Mirror(reflecting: self).descendant(name)!
  }
  
  public var allKeyPaths: [PartialKeyPath<Self>] {
    let metadata = reflect(Self.self) as! StructMetadata
    
    var keyPaths = [PartialKeyPath<Self>]()
    
    for field in metadata.descriptor.fields.records {
      let kp = \Self.[field.name]
      keyPaths.append(kp)
    }
    
    return keyPaths
  }
}
