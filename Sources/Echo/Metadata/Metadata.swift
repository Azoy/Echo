//
//  Metadata.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/14/19.
//

import Foundation

public protocol Metadata {
  var ptr: UnsafeRawPointer { get }
  var vwt: ValueWitnessTable { get }
  var kind: MetadataKind { get }
}

extension Metadata {
  public var vwt: ValueWitnessTable {
    let address = ptr.offset(of: -1, as: Int.self)
    return address.load(as: UnsafePointer<ValueWitnessTable>.self).pointee
  }
}

public enum MetadataKind: Int {
  case `class` = 0
  case `struct` = 512 // (0 | Flags.isNonHeap)
  case `enum` = 513 // (1 | Flags.isNonHeap)
  case optional = 514 // (2 | Flags.isNonHeap)
  case foreignClass = 515 // (3 | Flags.isNonHeap)
  case opaque = 768 // (0 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case tuple = 769 // (1 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case function = 770 // (2 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case existential = 771 // (3 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case metatype = 772 // (4 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case objcClassWrapper = 773 // (5 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case existentialMetatype = 774 // (6 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case heapLocalVariable = 1024 // (0 | Flags.isNonType)
  case heapGenericLocalVariable = 1280 // (0 | Flags.isRuntimePrivate | Flags.isNonType)
  case errorObject = 1281 // (1 | Flags.isRuntimePrivate | Flags.isNonType)
}

extension MetadataKind {
  public enum Flags: Int {
    case isRuntimePrivate = 0x100
    case isNonHeap = 0x200
    case isNonType = 0x400
  }
}

func getMetadata(from ptr: UnsafeRawPointer) -> Metadata? {
  print("Kind: \(ptr.load(as: Int.self))")
  let kind = MetadataKind(rawValue: ptr.load(as: Int.self))!
  
  switch kind {
  case .struct:
    return StructMetadata(ptr: ptr)
  case .enum:
    return EnumMetadata(ptr: ptr)
  //case .tuple:
    //return TupleMetadata(ptr: ptr)
  default:
    return nil
  }
}
