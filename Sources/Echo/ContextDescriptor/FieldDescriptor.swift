//
//  FieldDescriptor.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

/// A special descriptor that describes a type's fields.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct FieldDescriptor: LayoutWrapper {
  typealias Layout = _FieldDescriptor
  
  /// Backing field descriptor pointer.
  let ptr: UnsafeRawPointer
  
  /// Whether or not this field descriptor has a mangled name.
  public var hasMangledTypeName: Bool {
    layout._mangledTypeName.offset != 0
  }
  
  /// The mangled name for this field descriptor.
  public var mangledTypeName: UnsafeRawPointer {
    address(for: \._mangledTypeName)
  }
  
  /// The superclass mangled name for a class.
  public var superclass: UnsafeRawPointer {
    address(for: \._superclass)
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
    Array(unsafeUninitializedCapacity: numFields) {
      for i in 0 ..< numFields {
        let address = trailing.offset(of: i, as: _FieldRecord.self)
        $0[i] = FieldRecord(ptr: address)
      }
      
      $1 = numFields
    }
  }
}

/// A record that describes a single stored property or an enum case.
///
/// ABI Stability: Stable since the following
///
///     | macOS | iOS/tvOS | watchOS | Linux | Windows |
///     |-------|----------|---------|-------|---------|
///     | 10.14 | 12.2     | 5.2     | NA    | NA      |
///
public struct FieldRecord: LayoutWrapper {
  typealias Layout = _FieldRecord
  
  /// Backing field record pointer.
  let ptr: UnsafeRawPointer
  
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
  public var mangledTypeName: UnsafeRawPointer {
    address(for: \._mangledTypeName)
  }
  
  /// The name of the field.
  public var name: String {
    address(for: \._fieldName).string
  }
  
  /// The reference storage modifer on this field, if any.
  public var referenceStorage: ReferenceStorageKind {
    var fieldTypePtr = mangledTypeName
    
    let firstChar = fieldTypePtr.load(as: CChar.self)

    // If the field name begins with a relative address, skip over that.
    if firstChar >= 0x1 && firstChar <= 0x1F {
      // Skip the first character.
      fieldTypePtr += 1
      
      // Skip over the relative address depending on what the first character is.
      // You can find something similar in Utils/Misc.swift.
      if firstChar >= 0x1 && firstChar <= 0x17 {
        fieldTypePtr += 4
      } else {
        fieldTypePtr += MemoryLayout<Int>.size
      }
    }
    
    let fieldType = fieldTypePtr.string
    let refStorageMangle = String(fieldType.suffix(2))
    
    guard let kind = ReferenceStorageKind(rawValue: refStorageMangle) else {
      return .none
    }
    
    return kind
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
