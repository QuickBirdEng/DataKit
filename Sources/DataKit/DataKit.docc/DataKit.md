# ``DataKit``

A declarative DSL for reading and writing binary-formatted data in Swift.

## Overview

DataKit lets you describe the byte layout of a value once and use that single declaration
to encode and decode it. It is built on Swift's result-builder DSL — the style is
deliberately reminiscent of SwiftUI, but where SwiftUI builds views from declarations,
DataKit builds binary `Data`.

A minimal example:

```swift
struct Header: ReadWritable {
    var magic: UInt16
    var count: UInt8

    init(from context: ReadContext<Header>) throws {
        magic = try context.read(for: \.magic)
        count = try context.read(for: \.count)
    }

    static var format: Format {
        \.magic
        \.count
    }
}

let header = try Header(data)          // decode
let bytes  = try header.write()        // encode
```

### The two-phase read model

Decoding a ``Readable`` runs in two phases:

1. The **format walk** parses each declared field from the input bytes and stores it in a
   ``ReadContext``, keyed by `KeyPath<Self, Value>`.
2. The **initializer** ``Readable/init(from:)-...`` retrieves those values back out of the
   context by the *same* key paths and assembles `self`.

The key paths used in the format declaration and in `init(from:)` must match exactly.
Mixing them up is not caught at compile time; instead ``ReadContext`` throws
``ReadContext/ValueDoesNotExistError`` at runtime.

Writes do not go through a context — the format walk reads values directly off `self` via
the same key paths.

### The environment

Like SwiftUI, DataKit propagates ambient state through an ``EnvironmentValues`` struct.
Built-in keys:

- ``EnvironmentValues/endianness`` (`nil` = host-native; explicit `.big` / `.little` is
  almost always what wire protocols want).
- ``EnvironmentValues/suffix`` (the terminator for variable-length sequences).
- ``EnvironmentValues/skipChecksumVerification`` (read but do not validate checksum bytes).

Scoped overrides are written with `.endianness(.big)`, `.suffix(0 as UInt8)`, etc. — the
previous value is restored once the wrapped subtree finishes.

### Scopes, checksums, and the round-trip invariant

A ``Scope`` carves out a sub-range of the surrounding container. The most common pairing
is `Scope { ... }` enclosing the payload, followed by a bare ``Checksum`` expression that
covers exactly the scoped bytes. `endInset:` on a read-side scope reserves trailing bytes
(e.g. the checksum's own footprint) so they are not part of the verified range.

A `ReadWritable` conformance should always round-trip: `try T(t.write()) == t`. The
helpers in `Tests/DataKitTests/Extensions.swift` exercise this invariant for every
existing model — when adding new fields or new primitives, add a round-trip test of your
own.

## Topics

### Core Protocols

- ``Readable``
- ``Writable``
- ``ReadWritable``

### Read and Write Containers

- ``ReadContext``
- ``ReadContainer``
- ``WriteContainer``

### Format Primitives

- ``Property``
- ``Convert``
- ``Custom``
- ``Using``
- ``Scope``
- ``Environment``
- ``OnRead``
- ``OnWrite``
- ``EnvironmentProperty``
- ``ChecksumProperty``

### Format Types

- ``FormatProperty``
- ``FormatType``
- ``ReadFormat``
- ``WriteFormat``
- ``ReadWriteFormat``
- ``ReadableProperty``
- ``WritableProperty``

### Result Builders

- ``FormatBuilder``
- ``DataBuilder``

### Environment

- ``EnvironmentValues``
- ``EnvironmentKey``
- ``Endianness``
- ``Suffix``

### Conversions

- ``Conversion``
- ``ReversibleConversion``
- ``PrefixCountArray``
- ``DynamicCountArray``

### Built-in Conformances

Integers (`Int`/`Int8`…`Int64`/`UInt`/`UInt8`…`UInt64`), floating-point (`Float16` on
arm64, `Float32`, `Float64`), `RawRepresentable` (where `RawValue` is `ReadWritable`),
and `Optional` (where `Wrapped` is `ReadWritable`) all conform automatically.

### Errors

- ``ConversionError``
- ``UnexpectedValueError``
