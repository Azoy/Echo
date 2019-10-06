//
//  FieldDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso on 8/17/19.
//

public struct FieldDescriptor {
  
  public let ptr: UnsafeRawPointer
  
  public var mangledTypeName: UnsafeRawPointer {
    let relativePtr = RelativeDirectPointer<CChar>(
      ptr: ptr,
      offset: ptr.load(as: Int32.self)
    )
    
    return relativePtr.address
  }
  
  public var superclass: Int32 {
    let address = ptr.offset(of: 1, as: Int32.self)
    return address.load(as: Int32.self)
  }
  
  public var kind: FieldDescriptorKind {
    let address = ptr.offset(of: 2, as: Int32.self)
    return FieldDescriptorKind(rawValue: address.load(as: UInt16.self))!
  }
  
  public var recordSize: UInt16 {
    // mangledName is at offset 0 (Int16 size)
    // superclass is at offset 2 (Int16 size)
    // kind is at offset 4 (Int16 size)
    let address = ptr.offset(of: 5, as: Int16.self)
    return address.load(as: UInt16.self)
  }
  
  public var numFields: UInt32 {
    let address = ptr.offset(of: 3, as: Int32.self)
    return address.load(as: UInt32.self)
  }
  
  public var records: [FieldRecord] {
    let address = ptr.offset(of: 4, as: Int32.self)
    
    var result = [FieldRecord]()
    
    for i in 0 ..< numFields {
      result.append(FieldRecord(ptr: address.advanced(by: 4 * 3 * Int(i))))
    }
    
    return result
  }
  
}

public struct FieldRecord {
  
  public let ptr: UnsafeRawPointer
  
  public var flags: FieldRecordFlags {
    ptr.load(as: FieldRecordFlags.self)
  }
  
  public var mangledTypeName: UnsafeRawPointer {
    let address = ptr.offset(of: 1, as: Int32.self)
    let relativePtr = RelativeDirectPointer<CChar>(
      ptr: address,
      offset: address.load(as: Int32.self)
    )
    
    return relativePtr.address
  }
  
  //public var type: Any.Type {
    
  //}
  
  public var fieldName: String {
    let address = ptr.offset(of: 2, as: Int32.self)
    let relativePtr = RelativeDirectPointer<CChar>(
      ptr: address,
      offset: address.load(as: Int32.self)
    )
    
    return String(cString: UnsafePointer<CChar>(relativePtr.address._rawValue))
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

public enum FieldRecordFlags: UInt32 {
  case none = 0x0
  case isIndirectCase = 0x1
  case isVar = 0x2
}
