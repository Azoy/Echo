//
//  Metadata.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import Foundation

public protocol Metadata {
  var ptr: UnsafeRawPointer { get }
  var kind: MetadataKind { get }
}

extension Metadata {
  public var vwt: ValueWitnessTable {
    let address = ptr.offset(of: -1)
    return address.load(as: UnsafePointer<ValueWitnessTable>.self).pointee
  }
  
  public var enumVwt: EnumValueWitnessTable {
    assert(kind == .enum || kind == .optional)
    let address = ptr.offset(of: -1)
    return address.load(as: UnsafePointer<EnumValueWitnessTable>.self).pointee
  }
  
  public var type: Any.Type {
    unsafeBitCast(ptr, to: Any.Type.self)
  }
  
  public var descriptor: ContextDescriptor? {
    switch self {
    case let structMetadata as StructMetadata:
      return structMetadata.descriptor
    case let enumMetadata as EnumMetadata:
      return enumMetadata.descriptor
    case let classMetadata as ClassMetadata:
      return classMetadata.descriptor
    default:
      return nil
    }
  }
  
  var genericArgPtr: UnsafeRawPointer? {
    switch self {
    case let structMetadata as StructMetadata:
      return structMetadata.genericArgPtr
    case let enumMetadata as EnumMetadata:
      return enumMetadata.genericArgPtr
    default:
      return nil
    }
  }
  
  public func allocateBoxForExistential(
    in container: UnsafeMutablePointer<ExistentialContainer>
  ) -> UnsafeRawPointer {
    guard !vwt.flags.isValueInline else {
      return container.raw
    }
    
    let box = swift_allocBox(for: self)
    container.pointee.data.0 = Int(bitPattern: box.heapObj)
    return box.buffer
  }
}

public enum MetadataKind: Int {
  case `class` = 0
  
  // (0 | Flags.isNonHeap)
  case `struct` = 512
  
  // (1 | Flags.isNonHeap)
  case `enum` = 513
  
  // (2 | Flags.isNonHeap)
  case optional = 514
  
  // (3 | Flags.isNonHeap)
  case foreignClass = 515
  
  // (0 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case opaque = 768
  
  // (1 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case tuple = 769
  
  // (2 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case function = 770
  
  // (3 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case existential = 771
  
  // (4 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case metatype = 772
  
  // (5 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case objcClassWrapper = 773
  
  // (6 | Flags.isRuntimePrivate | Flags.isNonHeap)
  case existentialMetatype = 774
  
  // (0 | Flags.isNonType)
  case heapLocalVariable = 1024
  
  // (0 | Flags.isRuntimePrivate | Flags.isNonType)
  case heapGenericLocalVariable = 1280
  
  // (1 | Flags.isRuntimePrivate | Flags.isNonType)
  case errorObject = 1281
}

extension MetadataKind {
  public enum Flags: Int {
    case isRuntimePrivate = 0x100
    case isNonHeap = 0x200
    case isNonType = 0x400
  }
}

func getMetadata(at ptr: UnsafeRawPointer) -> Metadata {
  let int = ptr.load(as: Int.self)
  let kind = MetadataKind(rawValue: int)
  
  switch kind {
  case .class:
    return ClassMetadata(ptr: ptr)
  case .struct:
    return StructMetadata(ptr: ptr)
  case .enum, .optional:
    return EnumMetadata(ptr: ptr)
  case .opaque:
    return OpaqueMetadata(ptr: ptr)
  case .tuple:
    return TupleMetadata(ptr: ptr)
  case .function:
    return FunctionMetadata(ptr: ptr)
  case .existential:
    return ExistentialMetadata(ptr: ptr)
  case .metatype:
    return MetatypeMetadata(ptr: ptr)
  case .objcClassWrapper:
    return ObjCClassWrapperMetadata(ptr: ptr)
  default:
    // ISA pointer. Obj-C compatibile
    if int > 2047 {
      return ClassMetadata(ptr: ptr)
    }
    
    fatalError()
  }
}
