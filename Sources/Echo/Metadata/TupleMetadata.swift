//
//  TupleMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct TupleMetadata: Metadata, LayoutWrapper {
  typealias Layout = _TupleMetadata
  
  public let ptr: UnsafeRawPointer
  
  public var numElements: Int {
    layout._numElements
  }
  
  public var labels: [String] {
    let base = String(cString: layout._labels)
    let split = base.split(
      separator: " ",
      maxSplits: numElements,
      omittingEmptySubsequences: false
    )
    
    var result = [String]()
    
    for i in 0 ..< numElements {
      result.append(String(split[i]))
    }
    
    return result
  }
  
  public var elements: [Element] {
    var result = [Element]()
    
    for i in 0 ..< numElements {
      let elementSize = MemoryLayout<_TupleElement>.size
      let address = ptr.offset(of: 3) + (i * elementSize)
      result.append(Element(ptr: address))
    }
    
    return result
  }
}

extension TupleMetadata {
  public struct Element: LayoutWrapper {
    typealias Layout = _TupleElement
    
    public let ptr: UnsafeRawPointer
    
    public var type: Any.Type {
      layout._metadata
    }
    
    public var metadata: Metadata {
      reflect(type)
    }
    
    public var offset: Int {
      Int(layout._offset)
    }
  }
}

struct _TupleMetadata {
  let _kind: Int
  let _numElements: Int
  let _labels: UnsafePointer<CChar>
}

struct _TupleElement {
  let _metadata: Any.Type
  #if canImport(Darwin)
  let _offset: Int
  #else
  let _offset: UInt32
  #endif
}
