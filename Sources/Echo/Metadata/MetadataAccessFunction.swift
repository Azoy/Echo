//
//  MetadataAccessFunction.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

import CEcho

/// The Metadata Access Function is a special function within every type
/// context descriptor that instantiates metadata of that type.
///
/// To give an example, consider the following:
///
///     struct Foo {}
///     struct Bar<T> {}
///
/// In this example, `Foo`'s metadata access function will just return the
/// already cached metadata, `Foo.self`. `Bar` in this case is special because
/// of the generic parameter meaning that any type can be held in there. The
/// Swift runtime does not instantiate every single type metadata combination
/// for `Bar`, instead it instantiates type metadata for combinations that are
/// asked for through this metadata access function. For example:
///
///     // In this case we ask for the Bar<Int> which the Swift runtime will
///     // generate metadata for, but in our case we just want the context
///     // descriptor.
///     let metadata = reflectStruct(Bar<Int>.self)!
///     let accessor = metadata.descriptor.accessor
///
///     // Here we call the accessor to give us complete metadata with the first
///     // argument to be a `String`.
///     print(accessor(.complete, String.self).type) // Bar<String>
public struct MetadataAccessFunction {
  let ptr: UnsafeRawPointer
  
  /// Calls the metadata access function.
  /// - Parameter request: `MetadataRequest` that instructs what state of metadata
  ///                      we want and whether we want to block or not. In most
  ///                      cases just ask for `.complete`.
  /// - Returns: `MetadataResponse` that has our requested metadata and tells
  ///            us what state that metadata is in.
  public func callAsFunction(
    _ request: MetadataRequest
  ) -> Echo.MetadataResponse {
    let response = echo_callAccessor0(ptr, request.bits)
    return unsafeBitCast(response, to: Echo.MetadataResponse.self)
  }
  
  /// Calls the metadata access function for a type who has no conformances on
  /// their generic parameters.
  /// - Parameter request: `MetadataRequest` that instructs what state of metadata
  ///                      we want and whether we want to block or not. In most
  ///                      cases just ask for `.complete`.
  /// - Parameter args: A variadic parameter for including generic arguments
  ///                   to types that have generic requirements in their type
  ///                   signature. This field MUST be correct for the function
  ///                   to work correctly.
  /// - Returns: `MetadataResponse` that has our requested metadata and tells
  ///            us what state that metadata is in.
  public func callAsFunction(
    _ request: MetadataRequest,
    _ args: Any.Type...
  ) -> Echo.MetadataResponse {
    var response = CEcho.MetadataResponse()
    
    switch args.count {
    case 0:
      response = echo_callAccessor0(ptr, request.bits)
    case 1:
      let arg0 = unsafeBitCast(args[0], to: UnsafeRawPointer.self)
      response = echo_callAccessor1(ptr, request.bits, arg0)
    case 2:
      let arg0 = unsafeBitCast(args[0], to: UnsafeRawPointer.self)
      let arg1 = unsafeBitCast(args[1], to: UnsafeRawPointer.self)
      response = echo_callAccessor2(ptr, request.bits, arg0, arg1)
    case 3:
      let arg0 = unsafeBitCast(args[0], to: UnsafeRawPointer.self)
      let arg1 = unsafeBitCast(args[1], to: UnsafeRawPointer.self)
      let arg2 = unsafeBitCast(args[2], to: UnsafeRawPointer.self)
      response = echo_callAccessor3(ptr, request.bits, arg0, arg1, arg2)
    default:
      args.withUnsafeBytes {
        response = echo_callAccessor(ptr, request.bits, $0.baseAddress!)
      }
    }
    
    return unsafeBitCast(response, to: Echo.MetadataResponse.self)
  }
  
  /// Calls the metadata access function for a type who has generic arguments
  /// that require conformances.
  ///
  /// Example:
  ///
  ///     protocol Testable {}
  ///     extension Int: Testable {}
  ///     extension Double: Testable {}
  ///
  ///     struct Foo<T: Testable> {}
  ///
  ///     // We need to grab Int's testable witness table.
  ///     let testableMetadata = reflect(Testable.self) as! ExistentialMetadata
  ///     let testable = testableMetadata.protocols[0]
  ///     var intTestable: WitnessTable? = nil
  ///
  ///     // Iterate through all of Int's conformances to find the Testable
  ///     // conformance.
  ///     for conformance in reflectStruct(Int.self)!.conformances {
  ///       if conformance.protocol == testable {
  ///         assert(!conformance.flags.hasGenericWitnessTable)
  ///         intTestable = conformance.witnessTablePattern
  ///       }
  ///     }
  ///
  ///     let fooMetadata = reflectStruct(Foo<Double>.self)!
  ///     let fooAccessor = fooMetadata.descriptor.accessor
  ///     // Foo<Int>
  ///     print(fooAccessor(.complete, (Int.self, intTestable)).type)
  ///
  /// - Parameter request: `MetadataRequest` that instructs what state of metadata
  ///                      we want and whether we want to block or not. In most
  ///                      cases just ask for `.complete`.
  /// - Parameter args: A variadic parameter for including generic arguments
  ///                   and witness tables to types that have generic
  ///                   requirements and conformances in their type signature.
  ///                   This field MUST be correct for the function to work
  ///                   correctly.
  /// - Returns: `MetadataResponse` that has our requested metadata and tells
  ///            us what state that metadata is in.
  public func callAsFunction(
    _ request: MetadataRequest,
    _ args: (Any.Type, WitnessTable?)...
  ) -> Echo.MetadataResponse {
    var response = CEcho.MetadataResponse()
    
    switch args.count {
    case 0:
      // Easy case: No key arguments and no witness tables.
      response = echo_callAccessor0(ptr, request.bits)
    
    case 1:
      // If we don't have a witness table, then it's just the key parameter
      // argument.
      guard let witnessTable = args[0].1 else {
        let arg0 = unsafeBitCast(args[0].0, to: UnsafeRawPointer.self)
        response = echo_callAccessor1(ptr, request.bits, arg0)
        break
      }
      
      // Otherwise we have arg0 being the key argument and arg1 being the
      // witness table.
      let arg0 = unsafeBitCast(args[0].0, to: UnsafeRawPointer.self)
      let arg1 = witnessTable.ptr
      response = echo_callAccessor2(ptr, request.bits, arg0, arg1)
    
    case 2:
      switch (args[0].1, args[1].1) {
      // In this case there were no witness tables passed, so it's a simple
      // 2 key argument call.
      case (nil, nil):
        let arg0 = unsafeBitCast(args[0].0, to: UnsafeRawPointer.self)
        let arg1 = unsafeBitCast(args[1].0, to: UnsafeRawPointer.self)
        response = echo_callAccessor2(ptr, request.bits, arg0, arg1)
      
      // In this case, only the first key argument has a witness table, so this
      // is a 3 argument call where the witness table is the last parameter.
      case (let witnessTable0?, nil):
        let arg0 = unsafeBitCast(args[0].0, to: UnsafeRawPointer.self)
        let arg1 = unsafeBitCast(args[1].0, to: UnsafeRawPointer.self)
        let arg2 = witnessTable0.ptr
        response = echo_callAccessor3(ptr, request.bits, arg0, arg1, arg2)
      
      // In this case, only the second key argument has a witness table, so this
      // is a 3 argument call where the witness table is the last parameter.
      case (nil, let witnessTable1?):
        let arg0 = unsafeBitCast(args[0].0, to: UnsafeRawPointer.self)
        let arg1 = unsafeBitCast(args[1].0, to: UnsafeRawPointer.self)
        let arg2 = witnessTable1.ptr
        response = echo_callAccessor3(ptr, request.bits, arg0, arg1, arg2)
      
      // Finally, we have the case where both of our key arguments have witness
      // tables associated with them. This is a 4 argument call, thus requiring
      // an array pointer pointing to the key arguments followed by the witness
      // tables.
      case (_?, _?):
        let buffer = createMetadataAccessBuffer(for: args)
        
        defer {
          buffer.deallocate()
        }
        
        response = echo_callAccessor(ptr, request.bits, buffer)
      }
    
    case 3:
      switch (args[0].1, args[1].1, args[2].1) {
      // Simple case where we don't have any witness tables which just uses
      // the 3 argument accessor.
      case (nil, nil, nil):
        let arg0 = unsafeBitCast(args[0].0, to: UnsafeRawPointer.self)
        let arg1 = unsafeBitCast(args[1].0, to: UnsafeRawPointer.self)
        let arg2 = unsafeBitCast(args[2].0, to: UnsafeRawPointer.self)
        response = echo_callAccessor3(ptr, request.bits, arg0, arg1, arg2)
      
      // Any other witness table requires us to use the buffer accessor.
      default:
        let buffer = createMetadataAccessBuffer(for: args)
        
        defer {
          buffer.deallocate()
        }
        
        response = echo_callAccessor(ptr, request.bits, buffer)
      }
    
    // Anything more than 4 args requires us to create a buffer even if there
    // are no witness tables (those should use the other callAsFunction...).
    default:
      let buffer = createMetadataAccessBuffer(for: args)
      
      defer {
        buffer.deallocate()
      }
      
      response = echo_callAccessor(ptr, request.bits, buffer)
    }
    
    return unsafeBitCast(response, to: Echo.MetadataResponse.self)
  }
}

// NOTE: It is up to the caller to deallocate the returned pointer here.
func createMetadataAccessBuffer(
  for args: [(Any.Type, WitnessTable?)]
) -> UnsafeMutableRawPointer {
  // Allocate at LEAST enough space to hold arg.count key arguments * 2 (one
  // for the key argument and one for the witness table). It is understood that
  // not all witness tables are required.
  let ptrSize = MemoryLayout<UnsafeRawPointer>.size
  let buffer = UnsafeMutableRawPointer.allocate(
    byteCount: ptrSize * args.count * 2,
    alignment: MemoryLayout<UnsafeRawPointer>.alignment
  )
  
  // First loop is inserting the key arguments at the front of the buffer.
  for i in 0 ..< args.count {
    buffer.storeBytes(
      of: args[0].0,
      toByteOffset: ptrSize * i,
      as: Any.Type.self
    )
  }
  
  // Second loop is for appending the witness tables behind the key arguments.
  var nextLoc = 0
  for i in 0 ..< args.count {
    if args[i].1 != nil {
      let offset = ptrSize * args.count
      let addr = ptrSize * nextLoc + offset
      buffer.storeBytes(
        of: args[i].1!.ptr,
        toByteOffset: addr,
        as: UnsafeRawPointer.self
      )
      
      nextLoc += 1
    }
  }
  
  return buffer
}
