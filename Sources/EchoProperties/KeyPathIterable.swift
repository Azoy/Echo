import Swift
import Echo

// - MARK: `KeyPathIterable` protocol

/// An implementation detail of `KeyPathIterable`; do not use this protocol
/// directly.
public protocol _KeyPathIterableBase {
  var _allNamedKeyPathsTypeErased: [(name: String, keyPath: AnyKeyPath)] { get }
}

public extension _KeyPathIterableBase {
  var _allKeyPathsTypeErased: [AnyKeyPath] {
    return _allNamedKeyPathsTypeErased.map { $0.keyPath }
  }
}

/// A type whose values provides custom key paths to properties or elements.
public protocol KeyPathIterable: _KeyPathIterableBase {
  /// A collection of all custom key paths of this value.
  var allNamedKeyPaths: [(name: String, keyPath: PartialKeyPath<Self>)] { get }
}

public extension KeyPathIterable {
  /// A collection of all custom key paths of this value.
  var allKeyPaths: [PartialKeyPath<Self>] {
    return allNamedKeyPaths.map { $0.keyPath }
  }
}

public extension KeyPathIterable {
  var _allNamedKeyPathsTypeErased: [(name: String, keyPath: AnyKeyPath)] {
    return allNamedKeyPaths.map { ($0.name, $0.keyPath as AnyKeyPath) }
  }
}

// - MARK: Key path APIs

public extension Reflection {
  /// Returns the collection of all key paths of this value.
  static func allKeyPaths<T>(for value: T) -> [PartialKeyPath<T>] {
    // If the value conforms to `_KeyPathIterableBase`, return `allKeyPaths`.
    if let keyPathIterable = value as? _KeyPathIterableBase {
      return keyPathIterable._allKeyPathsTypeErased.compactMap {
        $0 as? PartialKeyPath<T>
      }
    }
    // Otherwise, return stored property key paths.
    return allStoredPropertyKeyPaths(for: type(of: value))
  }

  static func allNamedKeyPaths<T>(
    for value: T
  ) -> [(name: String, keyPath: PartialKeyPath<T>)] {
    // If the value conforms to `_KeyPathIterableBase`, return
    // `allNamedKeyPaths`.
    if let keyPathIterable = value as? _KeyPathIterableBase {
      return keyPathIterable._allNamedKeyPathsTypeErased.compactMap { pair in
        (pair.keyPath as? PartialKeyPath<T>).map { kp in (pair.name, kp) }
      }
    }
    // Otherwise, return stored property key paths.
    return allNamedStoredPropertyKeyPaths(for: type(of: value)).map { $0 }
  }
}

// - MARK: `KeyPathIterable` conformances

/// Returns `true` if all of the given key paths are instances of
/// `WritableKeyPath<Root, Value>`.
private func areWritable<Root, Value>(
  _ namedKeyPaths: [(name: String, keyPath: PartialKeyPath<Root>)],
  valueType: Value.Type
) -> Bool {
  return !namedKeyPaths.contains(
    where: { entry in !(entry.keyPath is WritableKeyPath<Root, Value>) }
  )
}

extension Array: KeyPathIterable {
  public var allNamedKeyPaths: [(name: String, keyPath: PartialKeyPath<Array>)] {
    let result = indices.map { i in (i.description, \Array[i]) }
    assert(areWritable(result, valueType: Element.self))
    return result
  }
}

// `Dictionary` conforms to `KeyPathIterable` when `Key` is
// `LosslessStringConvertible`.
//
// This allows `var allNamedKeyPaths` to use keys' descriptions as key path
// names.

extension Dictionary: _KeyPathIterableBase
where Key: LosslessStringConvertible {}
extension Dictionary: KeyPathIterable where Key: LosslessStringConvertible {
  public var allNamedKeyPaths:
    [(name: String, keyPath: PartialKeyPath<Dictionary>)]
  {
    // Note: `Dictionary.subscript(_: Key)` returns `Value?` and can be used to
    // form `WritableKeyPath<Self, Value>` key paths. Force-unwrapping the
    // result is necessary so that the key path value type is `Value`, not
    // `Value?`.
    let result = keys.map { key in ("\(key)", \Dictionary[key]!) }
    assert(areWritable(result, valueType: Value.self))
    return result
  }
}
