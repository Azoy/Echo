//
//  Echo.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public func reflect<T>(_ type: T.Type) -> Metadata {
  let ptr = unsafeBitCast(type, to: UnsafeRawPointer.self)

  return getMetadata(at: ptr)
}
