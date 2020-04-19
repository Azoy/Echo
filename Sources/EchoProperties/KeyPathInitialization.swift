//
//  KeyPathInitialization.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2020 Alejandro Alonso. All rights reserved.
//

import Echo

func _instantiateKeyPathBuffer(
  _ metadata: TypeMetadata,
  _ leafIndex: Int,
  _ origDestData: UnsafeMutableRawBufferPointer
) {
  let destData = UnsafeMutableRawBufferPointer(
    start: origDestData.baseAddress! + MemoryLayout<Int>.size,
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
    let metadata = reflect(self) as! ClassMetadata
    var size = metadata.instanceSize
    
    let tailStride = MemoryLayout<Int32>.stride
    let tailAlignMask = MemoryLayout<Int32>.alignment - 1
    
    size += tailAlignMask
    size &= ~tailAlignMask
    size += tailStride * (bytes / 4)
    
    let alignment = metadata.instanceAlignmentMask | tailAlignMask
    
    let object = swift_allocObject(
      for: metadata,
      size: size,
      alignmentMask: alignment
    )
    
    guard object != nil else {
      fatalError("Allocating \(self) instance failed")
    }
    
    let base = UnsafeMutableRawPointer(mutating: object!.successor())
    
    body(UnsafeMutableRawBufferPointer(start: base, count: bytes))
    
    return unsafeBitCast(object, to: self)
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

var createdKeyPathCache = [UnsafeRawPointer: [Int: AnyKeyPath]]()

func createKeyPath(root: TypeMetadata, leaf: Int) -> AnyKeyPath {
  if let cachedType = createdKeyPathCache[root.ptr] {
    if let cachedKeyPath = cachedType[leaf] {
      return cachedKeyPath
    }
  }
  
  let field = root.contextDescriptor.fields.records[leaf]
  
  let keyPathTy = getKeyPathType(from: root, for: field)
  let instance = keyPathTy._create(capacityInBytes: 20) {
    _instantiateKeyPathBuffer(root, leaf, $0)
  }

  let heapObj = UnsafeRawPointer(Unmanaged.passRetained(instance).toOpaque())
  let keyPath = unsafeBitCast(heapObj, to: AnyKeyPath.self)
  createdKeyPathCache[root.ptr, default: [:]][leaf] = keyPath
  return keyPath
}
