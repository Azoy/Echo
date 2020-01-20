//
//  KnownMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

import CEcho

public enum KnownMetadata {}

extension KnownMetadata {
  public enum Builtin {}
}

extension KnownMetadata.Builtin {
  public static var int1: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt1Metadata())
  }
  
  public static var int7: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt7Metadata())
  }
  
  public static var int8: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt8Metadata())
  }
  
  public static var int16: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt16Metadata())
  }
  
  public static var int32: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt32Metadata())
  }
  
  public static var int64: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt64Metadata())
  }
  
  public static var int128: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt128Metadata())
  }
  
  public static var int256: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt256Metadata())
  }
  
  public static var int512: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinInt512Metadata())
  }
  
  public static var word: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinWordMetadata())
  }
  
  public static var fpiee16: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinFPIEE16Metadata())
  }
  
  public static var fpiee32: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinFPIEE32Metadata())
  }
  
  public static var fpiee64: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinFPIEE64Metadata())
  }
  
  public static var fpiee80: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinFPIEE80Metadata())
  }
  
  public static var fpiee128: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinFPIEE128Metadata())
  }
  
  public static var nativeObject: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinNativeObjectMetadata())
  }
  
  public static var bridgeObject: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinBridgeObjectMetadata())
  }
  
  public static var rawPointer: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinRawPointerMetadata())
  }
  
  public static var unsafeValueBuffer: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinUnsafeValueBufferMetadata())
  }
  
  public static var unknownObject: OpaqueMetadata {
    OpaqueMetadata(ptr: getBuiltinUnknownObjectMetadata())
  }
}
