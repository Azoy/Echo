//
//  ConformanceDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 - 2021 Alejandro Alonso. All rights reserved.
//

#if canImport(ObjectiveC)
import ObjectiveC
#endif

/// A structure that helps describe a particular conformance in Swift.
/// Information includes what type is being conformed to what protocol, some
/// flags like if the conformance is retroactive, has conditional requirements,
/// etc.
public struct ConformanceDescriptor: LayoutWrapper {
  typealias Layout = _ConformanceDescriptor
  
  let ptr: UnsafeRawPointer
  
  public var flags: Flags {
    layout._flags
  }
  
  public var `protocol`: ProtocolDescriptor {
    ProtocolDescriptor(ptr: address(for: \._protocol))
  }
  
  public var contextDescriptor: TypeContextDescriptor? {
    let start = address(for: \._typeRef)
    
    switch flags.typeReferenceKind {
    case .directTypeDescriptor:
      let ptr = start.relativeDirectAddress(as: _ContextDescriptor.self)
      return getContextDescriptor(at: ptr) as? TypeContextDescriptor
    case .indirectTypeDescriptor:
      let ptr = start.relativeDirectAddress(as: UnsafeRawPointer.self)
      return getContextDescriptor(at: ptr.load(as: UnsafeRawPointer.self)) as? TypeContextDescriptor
    default:
      return nil
    }
  }
  
  #if canImport(ObjectiveC)
  public var objcClass: ObjCClassWrapperMetadata? {
    let start = address(for: \._typeRef)
    
    switch flags.typeReferenceKind {
    case .directObjCClass:
      let ptr = start.relativeDirectAddress(as: CChar.self)
        .assumingMemoryBound(to: CChar.self)
      
      guard let anyClass = objc_lookUpClass(ptr) else {
        fatalError("No Objective-C class named \(ptr.string)")
      }
      
      return reflect(anyClass) as? ObjCClassWrapperMetadata
    case .indirectObjCClass:
      let ptr = start.relativeDirectAddress(as: _ClassMetadata.self)
      return ObjCClassWrapperMetadata(ptr: ptr)
    default:
      return nil
    }
  }
  #endif
}

struct _ConformanceDescriptor {
  let _protocol: RelativeIndirectablePointer<_ProtocolDescriptor>
  let _typeRef: Int32
  let _witnessTablePattern: RelativeDirectPointer<_WitnessTable>
  let _flags: ConformanceDescriptor.Flags
}
