//
//  FieldDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

public struct FieldDescriptor {
  public let ptr: UnsafeRawPointer
  
  var _descriptor: _FieldDescriptor {
    ptr.load(as: _FieldDescriptor.self)
  }
  
  public var hasMangledTypeName: Bool {
    _descriptor._mangledTypeName.offset != 0
  }
  
  public var mangledTypeName: UnsafePointer<CChar> {
    let address = _descriptor._mangledTypeName.address(from: ptr)
    return UnsafePointer<CChar>(address._rawValue)
  }
  
  public var superclass: UnsafePointer<CChar> {
    let address = _descriptor._superclass.address(from: ptr.offset32(of: 1))
    return UnsafePointer<CChar>(address._rawValue)
  }
  
  public var kind: FieldDescriptorKind {
    FieldDescriptorKind(rawValue: _descriptor._kind)!
  }
  
  public var recordSize: Int {
    Int(_descriptor._recordSize)
  }
  
  public var numFields: Int {
    Int(_descriptor._numFields)
  }
  
  public var records: [FieldRecord] {
    var result = [FieldRecord]()
    
    for i in 0 ..< numFields {
      let address = ptr.offset32(of: 4).advanced(by: i * recordSize)
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
    let address = _record._mangledTypeName.address(from: ptr.offset32(of: 1))
    return UnsafePointer<CChar>(address._rawValue)
  }
  
  public var name: String {
    let address = _record._fieldName.address(from: ptr.offset32(of: 2))
    return String(cString: UnsafePointer<CChar>(address._rawValue))
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
    (bits & 0x1) == 0x1
  }
  
  // IsVar = 0x2
  public var isVar: Bool {
    (bits & 0x2) == 0x2
  }
}
