//
//  WitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

public struct WitnessTable: LayoutWrapper {
  typealias Layout = _WitnessTable
  
  let ptr: UnsafeRawPointer
  
  public var conformanceDescriptor: ConformanceDescriptor {
    layout._conformance
  }
}

struct _WitnessTable {
  let _conformance: ConformanceDescriptor
}
