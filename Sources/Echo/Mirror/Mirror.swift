//
//  Mirror.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct Mirror {
  public let subjectType: Any.Type
  
  public var children: Swift.Mirror.Children
  
  public let displayStyle: Swift.Mirror.DisplayStyle?
  
  public init(reflecting instance: Any) {
    // If we have a custom reflectable, use that.
    if let customized = instance as? CustomReflectable {
      self.subjectType = customized.customMirror.subjectType
      self.children = customized.customMirror.children
      self.displayStyle = customized.customMirror.displayStyle
      
      return
    }
    
    // Otherwise, let's do some reflection :)
    self = reflectInstance(instance)
  }
  
  init(
    subjectType: Any.Type,
    children: Swift.Mirror.Children,
    displayStyle: Swift.Mirror.DisplayStyle?
  ) {
    self.subjectType = subjectType
    self.children = children
    self.displayStyle = displayStyle
  }
}
