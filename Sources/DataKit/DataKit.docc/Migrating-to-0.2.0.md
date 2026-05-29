# Migrating to 0.2.0

Upgrade dependent code from DataKit 0.1.x to 0.2.0.

## Overview

DataKit 0.2.0 adds full Swift Concurrency (`Sendable`) support and raises the minimum
Swift toolchain. There are no new format features and no behavior changes to existing,
correct code — but the new `Sendable` requirements and the removal of a couple of
incidental APIs are source-breaking. Most projects need only small, mechanical changes.

If your build was already clean under the Swift 6 language mode, you will likely need no
changes at all.

## Raise your toolchain to Swift 5.10

DataKit now declares `swift-tools-version: 5.10` and minimum platforms of iOS 13 /
macOS 10.15 / tvOS 13 / watchOS 6. Build with a Swift 5.10 or newer toolchain. (The
previously declared 5.4 floor was never actually buildable — the result-builder code
requires 5.7.)

## Make your types `Sendable`

`Readable`, `Writable`, and `ReadWritable` now refine `Sendable`. Every conforming type
must therefore be `Sendable`.

Value types whose stored properties are all `Sendable` get this for free — no annotation
needed. All standard-library conformers (integers, floating-point, `String`,
`RawRepresentable` enums, `Optional`) already satisfy it. You only need to act if one of
your conforming types stores a non-`Sendable` value:

```swift
// Before — compiled in 0.1.x
struct Packet: ReadWritable {
    var payload: NSMutableData   // not Sendable
    // ...
}

// After — make the type's storage Sendable, or mark the conformance @unchecked
// with a documented invariant if you are certain concurrent use is safe.
struct Packet: ReadWritable {
    var payload: Data            // Sendable
    // ...
}
```

The same applies to custom `FormatProperty` / `ReadableProperty` / `WritableProperty`
implementations: these protocols now refine `Sendable`, and their `Root` must be
`Sendable`.

## Mark `Custom` and `Convert` closures `@Sendable`

Closures passed to ``Custom`` and ``Convert`` (and the fluent ``Property`` helpers
`read`, `write`, `converted`) are now `@Sendable`. In practice this means a closure may no
longer capture non-`Sendable` mutable state. Most format closures are pure transforms and
need no change:

```swift
// Still compiles — pure transform, no captured mutable state
Convert(\.humidity) { Double($0) / 100 } writing: { UInt8($0 * 100) }
```

If a closure captures something non-`Sendable`, refactor so the captured value is either
`Sendable` or passed through the container/environment instead of captured.

## Use `Checksum` types that are `Sendable`

Checksum algorithms used inside a format must now be `Sendable`. The `CRC32`, `CRC16`,
etc. types from the re-exported `CRC` module already are, so standard usage is unaffected.
A custom `Checksum` conformer must be made `Sendable`.

## Wrap bare key paths outside builders with `Property`

`KeyPath` no longer conforms to ``FormatProperty`` / ``ReadableProperty`` /
``WritableProperty`` directly.

Inside a format builder, bare key-path syntax is unchanged — this still works exactly as
before:

```swift
static var format: Format {
    \.magic
    \.count
}
```

You only need to change code that passed a key path where a ``FormatProperty`` value was
expected **outside** a builder context. Wrap it explicitly:

```swift
// Before
let property = \MyType.field

// After
let property = Property(\MyType.field)
```

## Replace `CannotWriteNilError`

`CannotWriteNilError` has been removed; it was declared publicly but never thrown by the
library. If you referenced it by name, delete that reference. Nil handling on the write
side is unchanged: writing `nil` for an `Optional` field emits zero bytes.

## Bonus: `skipChecksumVerification` now works

This is a bug fix rather than a migration step, but worth knowing: in 0.1.x the
``EnvironmentValues/skipChecksumVerification`` flag was read but never acted upon, so
checksums were always verified. In 0.2.0 the flag correctly suppresses verification while
still consuming the checksum bytes. If you relied on the old (broken) behavior of "set the
flag but checksums verify anyway," remove the flag.
