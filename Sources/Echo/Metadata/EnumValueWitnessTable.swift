//
//  EnumValueWitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct EnumValueWitnessTable {
  // Extend value witness table...
  public let vwt: ValueWitnessTable
  
  public let getEnumTag: @convention(c) (
    // Enum value
    UnsafeRawPointer,
    // Metadata
    UnsafeRawPointer
  ) -> UInt32 // returns the tag value (which case value in [0..numElements-1])
  public let destructiveProjectEnumData: @convention(c) (
    // Enum value
    UnsafeRawPointer,
    // Metadata
    UnsafeRawPointer
  ) -> ()
  public let destructiveInjectEnumTag: @convention(c) (
    // Enum value
    UnsafeRawPointer,
    // Tag
    UInt32,
    // Metadata
    UnsafeRawPointer
  ) -> ()
}
