//
//  ImageInspection.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2021 Alejandro Alonso. All rights reserved.
//

import Foundation

#if canImport(MachO)
import MachO
#elseif canImport(Glibc)
import Glibc
#endif

let conformanceLock = NSLock()
var conformances = [UnsafeRawPointer: [ConformanceDescriptor]]()

@_cdecl("registerProtocolConformances")
func registerProtocolConformances(section: UnsafeRawPointer, size: Int) {
  for i in 0 ..< size / 4 {
    let start = section.offset(of: i, as: Int32.self)
    let ptr = start.relativeDirectAddress(as: _ConformanceDescriptor.self)
    let conformance = ConformanceDescriptor(ptr: ptr)
    
    #if canImport(ObjectiveC)
    if let objcClass = conformance.objcClass {
      conformanceLock.withLock {
        conformances[objcClass.ptr, default: []].append(conformance)
      }
      continue
    }
    #endif
    
    if let descriptor = conformance.contextDescriptor {
      conformanceLock.withLock {
        conformances[descriptor.ptr, default: []].append(conformance)
      }
    }
  }
}

//===----------------------------------------------------------------------===//
// Mach-O Image Inspection
//===----------------------------------------------------------------------===//

#if canImport(MachO)

#if arch(x86_64) || arch(arm64)
typealias mach_header_platform = mach_header_64
#else
typealias mach_header_platform = mach_header
#endif

@_cdecl("lookupSection")
func lookupSection(
  _ header: UnsafePointer<mach_header>?,
  segment: UnsafePointer<CChar>?,
  section: UnsafePointer<CChar>?,
  do handler: @convention(c) (UnsafeRawPointer, Int) -> ()
) {
  guard let header = header else {
    return
  }
  
  var size: UInt = 0
  
  let section = header.withMemoryRebound(
    to: mach_header_platform.self,
    capacity: 1
  ) {
    getsectiondata($0, segment, section, &size)
  }
  
  guard section != nil else {
    return
  }
  
  handler(section!, Int(size))
}

#endif

//===----------------------------------------------------------------------===//
// ELF Image Inspection
//===----------------------------------------------------------------------===//

#if os(Linux)

let sharedObjectLock = NSLock()
var sharedObjects = Set<String>()

@_cdecl("cacheSharedObject")
func cacheSharedObject(cString: UnsafePointer<CChar>) -> Bool {
  let str = String(cString: cString)
  
  let entry = sharedObjectLock.withLock {
    sharedObjects.insert(str)
  }
  
  return entry.inserted
}

#endif
