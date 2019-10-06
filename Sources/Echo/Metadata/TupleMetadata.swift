//
//  TupleMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

/*
public struct TupleMetadata: Metadata {
  
  let ptr: UnsafeRawPointer
  
  public var vwt: ValueWitnessTable {
    ptr.get(UnsafePointer<ValueWitnessTable>.self, offset: -1).pointee
  }
  
  public var kind: MetadataKind {
    .tuple
  }
  
  public var numElements: Int {
    ptr.get(Int.self, offset: 1)
  }
  
  public var labels: [String] {
    let labels = ptr.get(UnsafePointer<CChar>?.self, offset: 2)
    
    guard labels != nil else {
      return []
    }
    
    return String(cString: labels!).split(separator: " ").map { String($0) }
  }
  
  public var elements: UnsafeBufferPointer<TupleElement> {
    let address = ptr.offset(of: 3)
    let buffer = UnsafeRawBufferPointer(
      start: address,
      count: MemoryLayout<TupleElement>.size * numElements
    )
    return buffer.bindMemory(to: TupleElement.self)
  }
  
}

extension TupleMetadata {
  public struct TupleElement {
    let _type: UnsafeRawPointer
    public let offset: Int
    
    public var type: Metadata {
      getMetadata(from: _type)!
    }
  }
}
*/
