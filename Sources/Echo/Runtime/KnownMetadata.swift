//
//  KnownMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import CEcho

public enum KnownMetadata {}

extension KnownMetadata {
  public enum Builtin {}
}

extension KnownMetadata.Builtin {
  public static var NativeObject: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinNativeObjectMetadata())
  }
}
