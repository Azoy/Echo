//
//  HeapObject.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct HeapObject {
  let _metadata: UnsafeRawPointer
  let _refCount: UInt64
}
