//
//  ReflectionMirror.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

func reflectInstance(_ instance: Any) -> Echo.Mirror {
  let subjectType = type(of: instance)
  let metadata = reflect(subjectType)
  
  let children = getChildren(of: instance, with: metadata)
  let displayStyle = getDisplayStyle(of: metadata)
  
  return Echo.Mirror(
    subjectType: subjectType,
    children: Swift.Mirror.Children(children),
    displayStyle: displayStyle
  )
}

func getDisplayStyle(of metadata: Metadata) -> Swift.Mirror.DisplayStyle? {
  switch metadata.kind {
  case .class:
    return .class
  case .enum:
    return .enum
  case .struct:
    return .struct
  case .tuple:
    return .tuple
  default:
    return nil
  }
}

func getChildren(
  of instance: Any,
  with metadata: Metadata
) -> [Swift.Mirror.Child] {
  switch metadata {
  case let structMetadata as StructMetadata:
    return getStructFields(from: instance, with: structMetadata)
  case let tupleMetadata as TupleMetadata:
    return getTupleFields(from: instance, with: tupleMetadata)
  case let enumMetadata as EnumMetadata:
    return getEnumFields(from: instance, with: enumMetadata)
  case let classMetadata as ClassMetadata:
    return getClassFields(from: instance, with: classMetadata)
  default:
    break
  }
  
  return []
}

func getStructFields(
  from instance: Any,
  with metadata: StructMetadata
) -> [Swift.Mirror.Child] {
  guard metadata.descriptor.isReflectable else {
    return []
  }
  
  var container = unsafeBitCast(instance, to: ExistentialContainer.self)
  let opaqueValue = container.projectValue()
  
  var result = [Swift.Mirror.Child]()
  
  for i in 0 ..< metadata.descriptor.numFields {
    let field = metadata.descriptor.fields.records[i]
    let label = field.name
    let type = Echo.type(
      of: field.mangledTypeName,
      context: metadata.descriptor.ptr,
      // FIXME: I need to expose this sometime...
      genericArgs: metadata.ptr.advanced(by: MemoryLayout<Int>.size * 2)
    )!
    let fieldMetadata = reflect(type)
    let offset = metadata.fieldOffsets[i]
    var value = ExistentialContainer(type: fieldMetadata)
    let buffer = withUnsafeMutablePointer(to: &value) {
      fieldMetadata.allocateBoxForExistential(in: $0)
    }
    _ = fieldMetadata.vwt.initializeWithCopy(
      buffer,
      opaqueValue.advanced(by: offset),
      fieldMetadata.ptr
    )
    
    result.append((label: label, value: unsafeBitCast(value, to: Any.self)))
  }
  
  return result
}

func getTupleFields(
  from instance: Any,
  with metadata: TupleMetadata
) -> [Swift.Mirror.Child] {
  var container = unsafeBitCast(instance, to: ExistentialContainer.self)
  let opaqueValue = container.projectValue()
  
  var result = [Swift.Mirror.Child]()
  
  let labels = metadata.labels.split(
    separator: " ",
    maxSplits: metadata.numElements,
    omittingEmptySubsequences: false
  )
  
  for i in 0 ..< metadata.numElements {
    var label = String(labels[i])
    if label.isEmpty {
      label = ".\(i)"
    }
    
    let elt = metadata.elements[i]
    var value = ExistentialContainer(type: elt.metadata)
    let buffer = withUnsafeMutablePointer(to: &value) {
      elt.metadata.allocateBoxForExistential(in: $0)
    }
    _ = elt.metadata.vwt.initializeWithCopy(
      buffer,
      opaqueValue.advanced(by: elt.offset),
      elt.metadata.ptr
    )
    
    result.append((label: label, value: unsafeBitCast(value, to: Any.self)))
  }
  
  return result
}

func getEnumFields(
  from instance: Any,
  with metadata: EnumMetadata
) -> [Swift.Mirror.Child] {
  guard metadata.descriptor.isReflectable else {
    return []
  }
  
  var container = unsafeBitCast(instance, to: ExistentialContainer.self)
  var opaqueValue = container.projectValue()
  
  var result = [Swift.Mirror.Child]()
  
  let tag = metadata.enumVwt.getEnumTag(opaqueValue, metadata.ptr)
  let field = metadata.descriptor.fields.records[Int(tag)]
  let name = field.name
  let type = Echo.type(
    of: field.mangledTypeName,
    context: metadata.descriptor.ptr,
    // FIXME: expose this
    genericArgs: metadata.ptr.offset(of: 2)
  )
  
  // If we have no payload case, or if the enum is not indirect, we're done.
  guard type != nil || field.flags.isIndirectCase else {
    return result
  }
  
  let nativeObject = reflect(_typeByName("Bo")!)
  let payloadMetadata = field.flags.isIndirectCase ?
                          nativeObject : reflect(type!)
  let pair = allocBox(for: payloadMetadata)
  
  metadata.enumVwt.destructiveProjectEnumData(opaqueValue, metadata.ptr)
  _ = payloadMetadata.vwt.initializeWithCopy(
    pair.buffer,
    opaqueValue,
    payloadMetadata.ptr
  )
  metadata.enumVwt.destructiveInjectEnumTag(opaqueValue, tag, metadata.ptr)
  
  opaqueValue = pair.buffer
  
  if field.flags.isIndirectCase {
    let owner = UnsafePointer<UnsafePointer<HeapObject>>(
      opaqueValue._rawValue
    ).pointee
    opaqueValue = projectBox(for: owner)
  }
  
  var value = ExistentialContainer(type: payloadMetadata)
  let buffer = withUnsafeMutablePointer(to: &value) {
    payloadMetadata.allocateBoxForExistential(in: $0)
  }
  _ = payloadMetadata.vwt.initializeWithCopy(
    buffer,
    opaqueValue,
    payloadMetadata.ptr
  )
  
  release(pair.heapObj)
  
  result.append((label: name, value: unsafeBitCast(value, to: Any.self)))
  
  return result
}

// FIXME: Handle ObjC stuff
func getClassFields(
  from instance: Any,
  with metadata: ClassMetadata
) -> [Swift.Mirror.Child] {
  guard metadata.descriptor.isReflectable else {
    return []
  }
  
  var result = [Swift.Mirror.Child]()
  
  for i in 0 ..< metadata.descriptor.numFields {
    let field = metadata.descriptor.fields.records[i]
    let label = field.name
    let type = Echo.type(
      of: field.mangledTypeName,
      context: metadata.descriptor.ptr,
      // FIXME: I need to expose this sometime...
      genericArgs: metadata.ptr.advanced(by: MemoryLayout<Int>.size * 2)
    )!
    let fieldMetadata = reflect(type)
    let offset = metadata.fieldOffsets[i]
    var value = ExistentialContainer(type: fieldMetadata)
    let buffer = withUnsafeMutablePointer(to: &value) {
      fieldMetadata.allocateBoxForExistential(in: $0)
    }
    withUnsafePointer(to: instance) {
      _ = fieldMetadata.vwt.initializeWithCopy(
        buffer,
        UnsafePointer<UnsafeRawPointer>($0.raw._rawValue).pointee.advanced(by: offset),
        fieldMetadata.ptr
      )
    }
    
    result.append((label: label, value: unsafeBitCast(value, to: Any.self)))
  }
  
  return result
}
