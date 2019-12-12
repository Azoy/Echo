//
//  HeapObject.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct HeapObject {
  public let _metadata: Any.Type
  public let _refCount: UInt64
}
