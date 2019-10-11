//
//  TupleMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/15/19.
//

public struct TupleMetadata: Metadata {
  public let ptr: UnsafeRawPointer
  
  var _tuple: _TupleMetadata {
    ptr.load(as: _TupleMetadata.self)
  }
  
  public var kind: MetadataKind {
    .tuple
  }
  
  public var numElements: Int {
    _tuple._numElements
  }
  
  public var labels: String {
    String(cString: _tuple._labels)
  }
  
  public var elements: [Element] {
    var result = [Element]()
    
    for i in 0 ..< numElements {
      let elementSize = MemoryLayout<_TupleElement>.size
      let address = ptr.offset(of: 3).advanced(by: i * elementSize)
      result.append(Element(ptr: address))
    }
    
    return result
  }
}

extension TupleMetadata {
  public struct Element {
    public let ptr: UnsafeRawPointer
    
    var _element: _TupleElement {
      ptr.load(as: _TupleElement.self)
    }
    
    public var type: Any.Type {
      unsafeBitCast(_element._metadata, to: Any.Type.self)
    }
    
    public var metadata: Metadata {
      getMetadata(at: _element._metadata)
    }
    
    public var offset: Int {
      Int(_element._offset)
    }
  }
}

struct _TupleMetadata {
  let _kind: Int
  let _numElements: Int
  let _labels: UnsafePointer<CChar>
}

struct _TupleElement {
  let _metadata: UnsafeRawPointer
  #if canImport(Darwin)
  let _offset: Int
  #else
  let _offset: UInt32
  #endif
}
