# Echo

A complete reflection package for Swift.

[![Build Status](https://travis-ci.com/Azoy/Echo.svg?branch=main)](https://travis-ci.com/Azoy/Echo/pull_requests)

## Installation

Simply add the following dependency to your  `Package.swift`:

```swift
.package(url: "https://github.com/Azoy/Echo.git", from: "0.0.1")
```

## Usage

```swift
let arrayOfInt = reflect([Int].self) as! StructMetadata
print(arrayOfInt.descriptor.name) // Array
print(arrayOfInt.genericTypes) // [Swift.Int]

let add = reflect(((Int, Int) -> Int).self) as! FunctionMetadata
print(add.resultType) // Int
print(add.paramTypes) // [Swift.Int, Swift.Int]

let point = reflect((x: Double, y: Double).self) as! TupleMetadata
print(point.numElements) // 2
print(point.labels) // ["x", "y"]
for element in point.elements {
  print(element.type) // Swift.Double, Swift.Double
  print(element.offset) // 0, 8
}
```
