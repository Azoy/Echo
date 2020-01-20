//
//  HeapLocalVariableMetadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

/// The metadata structure that represents local variables that are heap
/// allocated.
public struct HeapLocalVariableMetadata: Metadata, LayoutWrapper {
  typealias Layout = _HeapLocalVariableMetadata
  
  /// Backing heap local variable metadata pointer.
  public let ptr: UnsafeRawPointer
  
  public var offsetToFirstCapture: Int {
    Int(layout._offsetToFirstCapture)
  }
  
  public var captureDescription: UnsafePointer<CChar> {
    layout._captureDescription
  }
}

struct _HeapLocalVariableMetadata {
  let _kind: Int
  let _offsetToFirstCapture: UInt32
  let _captureDescription: UnsafePointer<CChar>
}
