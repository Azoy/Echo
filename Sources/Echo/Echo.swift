//
//  Echo.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public func reflect(_ type: Any.Type) -> Metadata {
  let ptr = unsafeBitCast(type, to: UnsafeRawPointer.self)

  return getMetadata(at: ptr)
}
