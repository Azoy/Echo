//
//  KeyPaths.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 - 2021 Alejandro Alonso. All rights reserved.
//

/*
extension AnyKeyPath {
  public var keyPathObject: KeyPathObject {
    // Because keypaths are classes, they are just pointers to a heap object.
    KeyPathObject(ptr: unsafeBitCast(self, to: UnsafeRawPointer.self))
  }
}

public struct KeyPathObject: LayoutWrapper {
  typealias Layout = _KeyPathObject
  
  public let ptr: UnsafeRawPointer
  
  public var heapObject: HeapObject {
    layout._heapObject
  }
  
  public var kvcString: String? {
    layout._kvc?.string
  }
  
  public var bufferHeader: KeyPathBufferHeader {
    layout._bufferHeader
  }
  
  public var components: [KeyPathComponent] {
    var result = [KeyPathComponent]()
    
    var componentPtr = ptr.offset(of: 4)
    var bufferSize = Int(bufferHeader.size)
    
    while bufferSize > 0 {
      let component = KeyPathComponent(ptr: componentPtr)
      result.append(component)
      
      switch component.kind {
      case .external,
           .struct,
           .class,
           .optionalChain,
           .optionalWrap,
           .optionalForce:
        // This includes the component itself (along with the padding on 64 bit
        // machines) and the metadata pointer afterwards.
        componentPtr = componentPtr.offset(of: 2)
        bufferSize -= MemoryLayout<Int>.size * 2
        
        // However, if the offset is too large for the payload space then there
        // will be another 4 byte payload immediately after the component. 64
        // bit machines don't have to worry about this because the padding is
        // used, but on 32 bit theres an extra payload we have to take into
        // account.
        if MemoryLayout<Int>.size == 4 && component.hasTrailingPayload {
          componentPtr = componentPtr.offset(of: 1)
          bufferSize -= MemoryLayout<Int>.size
        }
        
      case .computed:
        // 1 offset is the component, the other 2 are the identifier pointer
        // and the getter pointer. On 64 bit machines this includes the padding
        // after the component.
        componentPtr = componentPtr.offset(of: 3)
        bufferSize -= MemoryLayout<Int>.size * 3
        
        // An optional setter pointer if the computed proptery is settable.
        // (Not settable for a get only or a nonmutating set).
        if component.isComputedSettable {
          componentPtr = componentPtr.offset(of: 1)
          bufferSize -= MemoryLayout<Int>.size
        }
        
        // Computed components have a 2 word header that include 1. the amount
        // of bytes the captures are and 2. a pointer to the argument witness
        // table.
        if component.hasCapturedArguments {
          let argumentSize = componentPtr.load(as: Int.self)

          componentPtr = componentPtr.offset(of: 2)
          bufferSize -= MemoryLayout<Int>.size * 2
          
          // Advance argumentSize bytes.
          componentPtr += argumentSize
          bufferSize -= argumentSize
        }
        
        // And finally, the metadata pointer.
        componentPtr = componentPtr.offset(of: 1)
        bufferSize -= MemoryLayout<Int>.size
      }
    }
    
    return result
  }
}

extension KeyPathObject: CustomStringConvertible {
  public var description: String {
    let components = self.components
    
    assert(heapObject.metadata.kind == .class,
           "KeyPath class object that's not a class?")
    let classMetadata = heapObject.metadata as! ClassMetadata
    assert(classMetadata.genericTypes.count == 2,
           "KeyPath type without 2 generic types? Root and Leaf?")
    let root = classMetadata.genericTypes[0]
    
    guard components.allSatisfy({ $0.kind == .struct ||
                                  $0.kind == .class }) else {
      return "\(classMetadata.type)"
    }
    
    var currentRoot = reflect(root) as! TypeMetadata
    var fields = currentRoot.contextDescriptor.fields
    var fieldOffsets = currentRoot.fieldOffsets
    var result = "\\\(root)."
    
    for component in components {
      for (i, fieldOffset) in fieldOffsets.enumerated() {
        if component.storedOffset == fieldOffset {
          let field = fields.records[i]
          let fieldName = field.name
          result += "\(fieldName)."
          
          let fieldType = currentRoot.type(of: field.mangledTypeName)!
          
          // If the field type is not a nominal type, then this is our last
          // component.
          guard let newRoot = reflect(fieldType) as? TypeMetadata else {
            break
          }
          
          currentRoot = newRoot
          fields = currentRoot.contextDescriptor.fields
          fieldOffsets = currentRoot.fieldOffsets
        }
      }
    }
    
    result.removeLast()
    
    return result
  }
}

extension AnyKeyPath: CustomStringConvertible {
  public var description: String {
    keyPathObject.description
  }
}

public struct KeyPathBufferHeader {
  public let bits: UInt32
  
  public init(hasReferencePrefix: Bool, isTrivial: Bool, size: UInt32) {
    var bits = size
    
    if hasReferencePrefix {
      bits |= 0x40000000
    }
    
    if isTrivial {
      bits |= 0x80000000
    }
    
    self.bits = bits
  }
  
  public var hasReferencePrefix: Bool {
    bits & 0x40000000 != 0
  }
  
  public var isTrivial: Bool {
    bits & 0x80000000 != 0
  }
  
  public var size: UInt32 {
    bits & 0xFFFFFF
  }
}

public struct KeyPathComponent: LayoutWrapper {
  typealias Layout = UInt32
  
  let ptr: UnsafeRawPointer
  
  public var hasCapturedArguments: Bool {
    precondition(kind == .computed)
    return layout & 0x80000 != 0
  }
  
  var hasTrailingPayload: Bool {
    return payload == 0xFFFFFF
  }
  
  public var identifierKind: (Bool, Bool) {
    (layout & 0x200000 != 0, layout & 0x100000 != 0)
  }
  
  public var isComputedMutating: Bool {
    precondition(kind == .computed)
    return layout & 0x800000 != 0
  }
  
  public var isComputedSettable: Bool {
    precondition(kind == .computed)
    return layout & 0x400000 != 0
  }
  
  public var isEndOfReferencePrefix: Bool {
    layout & 0x80000000 != 0
  }
  
  public var kind: Kind {
    switch (layout & 0x7F000000) >> 24 {
    case 0:
      return .external
    case 1:
      return .struct
    case 2:
      return .computed
    case 3:
      return .class
    case 4: // .optional
      switch payload {
      case 0:
        return .optionalChain
      case 1:
        return .optionalWrap
      case 2:
        return .optionalForce
      default:
        fatalError("Invalid optional key path component payload")
      }
    default:
      fatalError("Invalid key path component kind")
    }
  }
  
  public var payload: UInt32 {
    layout & 0xFFFFFF
  }
  
  public var storedOffset: Int {
    precondition(kind == .struct || kind == .class)
    guard !hasTrailingPayload else {
      return Int(trailing.load(as: UInt32.self))
    }
    
    return Int(payload)
  }
}

extension KeyPathComponent {
  public enum Kind {
    case external
    case `struct`
    case computed
    case `class`
    case optionalChain
    case optionalWrap
    case optionalForce
  }
}

struct _KeyPathObject {
  let _heapObject: HeapObject
  let _kvc: UnsafePointer<CChar>?
  let _bufferHeader: KeyPathBufferHeader
}
*/
