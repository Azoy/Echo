//
//  WitnessTable.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 - 2021 Alejandro Alonso. All rights reserved.
//

public struct WitnessTable: LayoutWrapper {
  typealias Layout = _WitnessTable
  
  let ptr: UnsafeRawPointer
  
  public var conformanceDescriptor: ConformanceDescriptor {
    layout._conformance
  }
  
  public var conditionalConformances: [WitnessTable] {
    let numConditional = conformanceDescriptor.flags.numConditionalRequirements
    
    guard numConditional != 0 else {
      return []
    }
    
    var result = [WitnessTable]()
    
    for i in 0 ..< numConditional {
      // Conditional conformance witness tables appear in the private section
      // of a witness table which is the allocated space above.
      let witnessTablePtr = ptr.offset(of: -1 - i)
                               .load(as: UnsafeRawPointer.self)
      result.append(WitnessTable(ptr: witnessTablePtr))
    }
    
    return result
  }
}

struct _WitnessTable {
  let _conformance: ConformanceDescriptor
}
