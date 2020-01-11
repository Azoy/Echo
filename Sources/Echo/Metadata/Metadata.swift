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
}

extension Metadata {
  public var type: Any.Type {
    unsafeBitCast(ptr, to: Any.Type.self)
  }
  
  public var vwt: ValueWitnessTable {
    let address = ptr.offset(of: -1)
    return ValueWitnessTable(ptr: address)
  }
  
  public var enumVwt: EnumValueWitnessTable {
    precondition(kind == .enum || kind == .optional)
    let address = ptr.offset(of: -1)
    return EnumValueWitnessTable(ptr: address)
  }
  
  public var kind: MetadataKind {
    MetadataKind(rawValue: ptr.load(as: Int.self))!
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
