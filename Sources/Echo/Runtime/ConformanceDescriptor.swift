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
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct ConformanceDescriptor: LayoutWrapper {
  typealias Layout = _ConformanceDescriptor
  
  let ptr: UnsafeRawPointer
  
  /// The specific flags that describe this conformance descriptor.
  public var flags: Flags {
    layout._flags
  }
  
  /// The protocol that this type conforms to.
  public var `protocol`: ProtocolDescriptor {
    ProtocolDescriptor(ptr: address(for: \._protocol))
  }
  
  /// The context descriptor of the type being conformed.
  public var contextDescriptor: TypeContextDescriptor? {
    let start = address(for: \._typeRef)
    
    switch flags.typeReferenceKind {
    case .directTypeDescriptor:
      let ptr = start.relativeDirectAddress(as: _ContextDescriptor.self)
      return getContextDescriptor(at: ptr) as? TypeContextDescriptor
    case .indirectTypeDescriptor:
      var ptr = start.relativeDirectAddress(as: UnsafeRawPointer.self)
      ptr = ptr.load(as: UnsafeRawPointer.self)
      return getContextDescriptor(at: ptr) as? TypeContextDescriptor
    default:
      return nil
    }
  }
  
  /// The ObjectiveC class metadata of the type being conformed.
  #if canImport(ObjectiveC)
  public var objcClass: ObjCClassWrapperMetadata? {
    let start = address(for: \._typeRef)
    
    switch flags.typeReferenceKind {
    case .directObjCClass:
      let ptr = start.relativeDirectAddress(as: CChar.self)
        .assumingMemoryBound(to: CChar.self)
      
      guard let anyClass = objc_lookUpClass(ptr) else {
        // A conformance with a nil class means the class was weak-linked
        // from a newer SDK and isn't available in this version of iOS 
        return nil
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
  
  /// The witness table pattern is a base witness table that this conformance
  /// can base actual witness tables off of. In the case that this conformance
  /// does not have a generic witness table (flags.hasGenericWitnessTable), this
  /// witness table pattern is actually the real witness table.
  public var witnessTablePattern: WitnessTable {
    WitnessTable(ptr: address(for: \._witnessTablePattern))
  }
}

struct _ConformanceDescriptor {
  let _protocol: RelativeIndirectablePointer<_ProtocolDescriptor>
  let _typeRef: Int32
  let _witnessTablePattern: RelativeDirectPointer<_WitnessTable>
  let _flags: ConformanceDescriptor.Flags
}
