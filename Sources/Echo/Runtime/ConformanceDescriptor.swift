//
//  ConformanceDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

public struct ConformanceDescriptor: LayoutWrapper {
  typealias Layout = _ConformanceDescriptor
  
  let ptr: UnsafeRawPointer
  
  public var flags: ConformanceFlags {
    layout._flags
  }
  
  public var `protocol`: ProtocolDescriptor {
    ProtocolDescriptor(ptr: address(for: \._protocol).raw)
  }
}

struct _ConformanceDescriptor {
  let _protocol: RelativeIndirectablePointer<_ProtocolDescriptor>
  let _typeRef: Int32
  let _witnessTablePattern: RelativeDirectPointer<_WitnessTable>
  let _flags: ConformanceFlags
}
