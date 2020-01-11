//
//  FieldDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

/// A special descriptor that describes a type's fields.
public struct FieldDescriptor: LayoutWrapper {
  typealias Layout = _FieldDescriptor
  
  /// Backing field descriptor pointer.
  public let ptr: UnsafeRawPointer
  
  /// Whether or not this field descriptor has a mangled name.
  public var hasMangledTypeName: Bool {
    layout._mangledTypeName.offset != 0
  }
  
  /// The mangled name for this field descriptor.
  public var mangledTypeName: UnsafePointer<CChar> {
    layout._mangledTypeName.address(from: ptr)
  }
  
  /// The superclass mangled name for a class.
  public var superclass: UnsafePointer<CChar> {
    let offset = ptr.offset(of: 1, as: Int32.self)
    return layout._superclass.address(from: offset)
  }
  
  /// The kind of field descriptor this is.
  public var kind: Kind {
    Kind(rawValue: layout._kind)!
  }
  
  /// The size in bytes of each field record.
  public var recordSize: Int {
    Int(layout._recordSize)
  }
  
  /// The number of fields (properties) that this type declares.
  public var numFields: Int {
    Int(layout._numFields)
  }
  
  /// An array of this type's field records.
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

/// A record that describes a single stored property or an enum case.
public struct FieldRecord: LayoutWrapper {
  typealias Layout = _FieldRecord
  
  /// Backing field record pointer.
  public let ptr: UnsafeRawPointer
  
  /// The flags that describe this field record.
  public var flags: Flags {
    layout._flags
  }
  
  /// Whether or not this record has a mangled type name that describes the
  /// fields type.
  public var hasMangledTypeName: Bool {
    layout._mangledTypeName.offset != 0
  }
  
  /// The mangled type name that demangles to the field's type.
  ///
  /// Note: Use this in combination with metadata's type(of:) method to get a
  ///       field's type.
  ///
  /// Example:
  ///     let metadata = reflect(SomeType.self) as! TypeMetadata
  ///     for field in metadata.contextDescriptor.fields.records {
  ///       let fieldType = metadata.type(of: field.mangledTypeName)
  ///     }
  public var mangledTypeName: UnsafePointer<CChar> {
    let offset = ptr.offset(of: 1, as: Int32.self)
    return layout._mangledTypeName.address(from: offset)
  }
  
  /// The name of the field.
  public var name: String {
    let offset = ptr.offset(of: 2, as: Int32.self)
    let address = layout._fieldName.address(from: offset)
    return String(cString: address)
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
  let _flags: FieldRecord.Flags
  let _mangledTypeName: RelativeDirectPointer<CChar>
  let _fieldName: RelativeDirectPointer<CChar>
}
