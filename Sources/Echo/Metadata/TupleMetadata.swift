//
//  TupleMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2020 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents a tuple type in Swift.
public struct TupleMetadata: Metadata, LayoutWrapper {
  typealias Layout = _TupleMetadata
  
  /// Backing tuple metadata pointer.
  public let ptr: UnsafeRawPointer
  
  /// The number of elements in this tuple.
  public var numElements: Int {
    layout._numElements
  }
  
  /// An array of labels for each element in this tuple.
  public var labels: [String] {
    let split = layout._labels.string.split(
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
  
  /// An array of elements that describe each tuple more in depth, including
  /// offset and type.
  public var elements: [Element] {
    var result = [Element]()
    
    for i in 0 ..< numElements {
      let address = trailing.offset(of: i, as: _TupleElement.self)
      result.append(Element(ptr: address))
    }
    
    return result
  }
}

extension TupleMetadata {
  /// The structure that represents a tuple element in some tuple metadata.
  public struct Element: LayoutWrapper {
    typealias Layout = _TupleElement
    
    /// Backing tuple element pointer.
    public let ptr: UnsafeRawPointer
    
    /// The type for this tuple element.
    public var type: Any.Type {
      layout._metadata
    }
    
    /// The metadata for the type for this tuple element.
    public var metadata: Metadata {
      reflect(type)
    }
    
    /// The offset in bytes to this element from a tuple pointer.
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
