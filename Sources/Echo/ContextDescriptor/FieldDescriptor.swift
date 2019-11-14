//
//  FieldDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct FieldDescriptor {
  public let ptr: UnsafeRawPointer
  
  var _fields: _FieldDescriptor {
    ptr.load(as: _FieldDescriptor.self)
  }
  
  public var hasMangledTypeName: Bool {
    _fields._mangledTypeName.offset != 0
  }
  
  public var mangledTypeName: UnsafePointer<CChar> {
    let address = _fields._mangledTypeName.address(from: ptr)
    return UnsafePointer<CChar>(address)
  }
  
  public var superclass: UnsafePointer<CChar> {
    let offset = ptr.offset(of: 1, as: Int32.self)
    let address = _fields._superclass.address(from: offset)
    return UnsafePointer<CChar>(address)
  }
  
  public var kind: FieldDescriptorKind {
    FieldDescriptorKind(rawValue: _fields._kind)!
  }
  
  public var recordSize: Int {
    Int(_fields._recordSize)
  }
  
  public var numFields: Int {
    Int(_fields._numFields)
  }
  
  public var records: [FieldRecord] {
    var result = [FieldRecord]()
    
    for i in 0 ..< numFields {
      let address = ptr.offset(of: 4, as: Int32.self)
                       .offset(of: i, as: _FieldRecord.self)
      result.append(FieldRecord(ptr: address))
    }
    
    return result
  }
}

public struct FieldRecord {
  public let ptr: UnsafeRawPointer
  
  var _record: _FieldRecord {
    ptr.load(as: _FieldRecord.self)
  }
  
  public var flags: FieldRecordFlags {
    _record._flags
  }
  
  public var hasMangledTypeName: Bool {
    _record._mangledTypeName.offset != 0
  }
  
  public var mangledTypeName: UnsafePointer<CChar> {
    let offset = ptr.offset(of: 1, as: Int32.self)
    let address = _record._mangledTypeName.address(from: offset)
    return UnsafePointer<CChar>(address)
  }
  
  public var name: String {
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = _record._fieldName.address(from: offset)
    return String(cString: UnsafePointer<CChar>(address))
  }
}

public enum FieldDescriptorKind: UInt16 {
  case `struct` = 0
  case `class` = 1
  case `enum` = 2
  case multiPayloadEnum = 3
  case `protocol` = 4
  case classProtocol = 5
  case objcProtocol = 6
  case objcClass = 7
}

public struct FieldRecordFlags {
  public let bits: UInt32
  
  // IsIndirectCase = 0x1
  public var isIndirectCase: Bool {
    bits & 0x1 != 0
  }
  
  // IsVar = 0x2
  public var isVar: Bool {
    bits & 0x2 != 0
  }
}

struct _FieldDescriptor {
  let _mangledTypeName: RelativeDirectPointer<CChar>
  let _superclass: RelativeDirectPointer<CChar>
  let _kind: UInt16
  let _recordSize: UInt16
  let _numFields: UInt32
}

struct _FieldRecord {
  let _flags: FieldRecordFlags
  let _mangledTypeName: RelativeDirectPointer<CChar>
  let _fieldName: RelativeDirectPointer<CChar>
}
