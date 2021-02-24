//
//  SignedPointer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

import CEcho

// A wrapper around a pointer who will return the signed version of the wrapped
// pointer through the `signed` property.
struct SignedPointer<Pointee> {
  var ptr: UnsafeRawPointer
  
  var signed: UnsafeRawPointer {
    ptr
  }
}

// Swift type descriptors are signed with the process independent data key.
#if _ptrauth(_arm64e)
extension SignedPointer where Pointee: TypeContextDescriptor {
  var signed: UnsafeRawPointer {
    __ptrauth_strip_asda(ptr)!
  }
}
#endif
