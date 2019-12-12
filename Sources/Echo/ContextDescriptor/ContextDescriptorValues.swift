//
//  ContextDescriptorValues.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

extension AnonymousDescriptor {
  public struct Flags {
    public let bits: UInt16
    
    public var hasMangledName: Bool {
      bits & 0x1 != 0
    }
  }
}
