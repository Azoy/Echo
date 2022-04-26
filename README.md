# Echo

[![Build Status](https://travis-ci.com/Azoy/Echo.svg?branch=main)](https://travis-ci.com/github/Azoy/Echo/pull_requests)

A complete reflection package for Swift.

Documentation: [Echo Wiki](https://github.com/Azoy/Echo/wiki)

## Installation

Depending on what version of Swift you are targeting, the installation and what version you install can differ.

Example 1: You are a developer who has an iOS app who supports Swift 5.0 - 5.3. In this case, you may want the `swift-5.0` branch to not have to worry about "is this thing I'm using only available on newer runtimes?"

Example 2: You have Swift on the server using Linux and want to include this dependency. This is easy because whatever version of Swift you're running, is the branch you need to include. Your SotS project uses Swift 5.3, so simply use the `swift-5.3` branch.

Example 3: You have some macOS app that is only supported on Swift 5.3 and will only ever support the latest version of Swift. Similar to the Swift of the Server example, you just need the latest `swift-5.3` branch and 

After understanding what branch you need to include, adding Echo is fairly simple using the Swift Package Manager to add a dependency:

```swift
.package(url: "https://github.com/Azoy/Echo.git", .branch("swift-5.3"))
```


## A note about ABI stability

This library exposes some metadata data structures that are not considered ABI stable on any platform, namely Tuple/Existential/Function/Metatype metadata. Although these metadata structures work if you're using the branch that matches the language runtime you're using, in the future these types may break. This is mostly a concern for those deploying applications on ABI stable platforms and need code to both work for the older runtimes and newer runtimes. If this is you, I highly suggest to read the documentation for all of the data structures you are using to ensure you're not using anything that could break in the future. If you're a developer deploying an application on a platform who does not have ABI stability, namely Linux and Windows, this should be of no concern to you because there is no guarantee anything will work across Swift versions, so it's up to you to update this dependency.

## Usage

Some example scenarios:

```swift
// Perhaps I need the generic argument to whatever type
// is passed in here.
func printGenericArgs<T>(with x: T) {
  guard let metadata = reflect(x) as? TypeMetadata else {
    return
  }

  print(metadata.genericTypes)
}

// [Swift.Int]
printGenericArgs(with: [1, 2, 3])

// [Swift.String, Swift.Int]
printGenericArgs(with: ["Romeo": 128, "Juliet": 129])
```

Or maybe you want to access all of the conformances for a type:

```swift
func printAllConformances<T>(for _: T.Type) {
  guard let metadata = reflect(T.self) as? TypeMetadata else {
    print("Not a TypeMetadata type!")
    return
  }

  for conformance in metadata.conformances {
    print("\(metadata.descriptor.name): \(conformance.protocol.name)")
  }
}

// ...
// Int: ExpressibleByIntegerLiteral
// Int: Comparable
// Int: Hashable
// Int: Equatable
// ...
printAllConformances(for: Int.self)
```
