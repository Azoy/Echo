//
//  RelativePointer.swift
//  Echo
//
//  Created by Alejandro Alonso
//  Copyright © 2019 - 2021 Alejandro Alonso. All rights reserved.
//

// This relative pointer design is a little different because typical Swift
// implementations would do withUnsafePointer(to: &self), etc. That's fine and
// all, but it requires marking the function mutating which requires the data
// structures that use them to mark mutating everywhere, and it gets ugly. I
// could do something like my current approach and make a copy in every accessor
// that uses a data structure with relative pointers, but it becomes repetitive
// writing `var _structure = _structure`. All of that for writing the naive way
// of porting relative references in Swift. My approach is a little more verbose
// accessing a relative pointer's value, but it doesn't require the var dance.
// I might reconsider this decision down the road, but for now this is what I'm
// going with. At the end of the day, I don't want to require the user to be
// forced to write `var metadata = reflect(type)` as a var when naturally the
// first instinct is to go for a let first.
protocol RelativePointer {
  associatedtype Pointee
  
  var offset: Int32 { get }
  
  func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer
  func pointee(from ptr: UnsafeRawPointer) -> Pointee?
}

extension RelativePointer {
  var isNull: Bool {
    offset == 0
  }
  
  func address(from ptr: UnsafeRawPointer) -> UnsafeRawPointer {
    ptr + Int(offset)
  }
}
