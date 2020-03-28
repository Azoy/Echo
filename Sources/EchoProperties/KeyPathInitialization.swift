//
//  KeyPathInitialization.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

import Swift
import Echo

func _instantiateKeyPathBuffer(
  _ metadata: TypeMetadata,
  _ leafIndex: Int,
  _ origDestData: UnsafeMutableRawBufferPointer
) {
  let destHeaderPtr = origDestData.baseAddress.unsafelyUnwrapped
  let destData = UnsafeMutableRawBufferPointer(
    start: destHeaderPtr.advanced(by: MemoryLayout<Int>.size),
    count: origDestData.count - MemoryLayout<Int>.size
  )
  
  let header = KeyPathBufferHeader(
    hasReferencePrefix: false,
    isTrivial: true,
    size: 4
  )
  
  destData.storeBytes(
    of: header,
    as: KeyPathBufferHeader.self
  )
  
  var componentBits = UInt32(metadata.fieldOffsets[leafIndex])
  componentBits |= metadata.kind == .struct ? 1 << 24 : 3 << 24
  
  destData.storeBytes(
    of: componentBits,
    toByteOffset: MemoryLayout<Int>.size,
    as: UInt32.self
  )
}

extension AnyKeyPath {
  static func _create(
    capacityInBytes bytes: Int,
    initializedBy body: (UnsafeMutableRawBufferPointer) -> ()
  ) -> Self {
    assert(bytes > 0 && bytes % 4 == 0,
           "capacity must be multiple of 4 bytes")
    let result = Builtin.allocWithTailElems_1(self, (bytes/4)._builtinWordValue,
                                              Int32.self)
    //result._kvcKeyPathStringPtr = nil
    let base = UnsafeMutableRawPointer(Builtin.projectTailElems(result,
                                                                Int32.self))
    body(UnsafeMutableRawBufferPointer(start: base, count: bytes))
    return result
  }
}

func getKeyPathType(
  from root: TypeMetadata,
  for leaf: FieldRecord
) -> AnyKeyPath.Type {
  let leafTy = root.type(of: leaf.mangledTypeName)!

  func openRoot<Root>(_: Root.Type) -> AnyKeyPath.Type {
    func openLeaf<Value>(_: Value.Type) -> AnyKeyPath.Type {
      switch root.kind {
      case .struct:
        return leaf.flags.isVar ? WritableKeyPath<Root, Value>.self
                                : KeyPath<Root, Value>.self
      case .class:
        return ReferenceWritableKeyPath<Root, Value>.self
      default:
        fatalError()
      }
    }
    
    return _openExistential(leafTy, do: openLeaf)
  }
  
  return _openExistential(root.type, do: openRoot)
}

func createKeyPath(root: TypeMetadata, leaf: Int) -> AnyKeyPath {
  let field = root.contextDescriptor.fields.records[leaf]
  
  let keyPathTy = getKeyPathType(from: root, for: field)
  let instance = keyPathTy._create(capacityInBytes: 20) {
    _instantiateKeyPathBuffer(root, leaf, $0)
  }

  let heapObj = UnsafeRawPointer(Unmanaged.passRetained(instance).toOpaque())
  return unsafeBitCast(heapObj, to: AnyKeyPath.self)
}
