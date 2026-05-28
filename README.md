![DataKit](https://github.com/QuickBirdEng/DataKit/assets/15239005/2b8fc619-2c29-4900-984b-9187ae7a5b57)

**A declarative DSL for binary protocols in Swift.**

- Round-trip reads ↔ writes from a single format declaration.
- Built on Swift result builders — feels like SwiftUI, but produces bytes.
- Handles real-world wire-protocol concerns: endianness, bit-packed flags, length prefixes, dynamic suffixes, and CRC checksums.

[![Swift Package Manager](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Documentation](https://swiftpackageindex.com/QuickBirdEng/DataKit/documentation)](https://swiftpackageindex.com/QuickBirdEng/DataKit/documentation)

---

## Contents

- [Installation](#installation)
- [Quick start](#quick-start)
- [Real-world example: weather-station packet](#real-world-example-weather-station-packet)
- [Concepts](#concepts)
- [Built-in conformances](#built-in-conformances)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add DataKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/QuickBirdEng/DataKit.git", from: "0.1.0"),
],
```

…and add `"DataKit"` to the dependencies list of any target that uses it. Xcode users can
also add the package via *File → Add Package Dependencies…*.

## Quick start

```swift
import DataKit

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

let header = try Header(data)            // decode
let bytes  = try header.write()          // encode
```

That's everything: one `format` declaration drives both directions. Key paths in
`format` and `init(from:)` must match — see the [reading footgun](#-heads-up-keypath-mismatch-is-a-runtime-error)
below.

## Real-world example: weather-station packet

A more realistic example exercises feature flags, conditional fields, conversion, and a
CRC trailer. Here is the on-the-wire layout we will model:

- Frame prefix: one byte `0x02`.
- One feature-flags byte:
  - bit 0: temperature is present
  - bit 1: humidity is present
  - bit 2: temperature is in °C (otherwise °F)
- If present: temperature as a big-endian 32-bit float.
- If present: humidity as a `UInt8` in the range `[0, 100]`, exposed as a `Double` in
  `[0, 1]`.
- A CRC-32 over the entire frame.

```swift
import DataKit

struct WeatherStationFeatures: OptionSet, ReadWritable {
    var rawValue: UInt8

    static var hasTemperature = Self(rawValue: 1 << 0)
    static var hasHumidity    = Self(rawValue: 1 << 1)
    static var usesMetricUnits = Self(rawValue: 1 << 2)
}

struct WeatherStationUpdate: ReadWritable {
    var features: WeatherStationFeatures
    var temperature: Measurement<UnitTemperature>
    var humidity: Double

    init(from context: ReadContext<Self>) throws {
        features = try context.read(for: \.features)
        temperature = try context.readIfPresent(for: \.temperature)
            ?? .init(value: .nan, unit: .kelvin)
        humidity = try context.readIfPresent(for: \.humidity) ?? .nan
    }

    static var format: Format {
        Scope {
            UInt8(0x02)                      // asserted on read, emitted on write
            \.features

            Using(\.features) { features in
                if features.contains(.hasTemperature) {
                    let unit: UnitTemperature =
                        features.contains(.usesMetricUnits) ? .celsius : .fahrenheit
                    Convert(\.temperature) {
                        $0.converted(to: unit).cast(Float.self)
                    }
                }
                if features.contains(.hasHumidity) {
                    Convert(\.humidity) {
                        Double($0) / 100
                    } writing: {
                        UInt8($0 * 100)
                    }
                }
            }

            CRC32.default                    // covers exactly the Scope's bytes
        }
        .endianness(.big)
    }
}

let packet: WeatherStationUpdate = ...
let bytes = try packet.write()
let decoded = try WeatherStationUpdate(bytes)
```

> If you only need one direction, conform to ``Readable`` or ``Writable`` and replace
> `format` with `readFormat` (plus the `init(from:)`) or `writeFormat`.

### ⚠️ Heads-up: keypath mismatch is a runtime error

The format walk stores each parsed value into a `ReadContext` keyed by a `KeyPath<Self,
Value>`. Your `init(from:)` retrieves it by the same key path. A mismatch (typo, renamed
field, or stale code) surfaces as `ReadContext.ValueDoesNotExistError` *at runtime* — the
compiler cannot catch it. Add a round-trip test for every `ReadWritable` to flush these
out early.

## Concepts

| Concept | When to reach for it | Source |
|---|---|---|
| [`Property`](#property) | Help the compiler with a key path it cannot infer; entry-point for fluent operators. | [`Property.swift`](Sources/DataKit/Property/Property.swift) |
| [`Convert`](#convert) | Encode a field as a different on-wire type than the in-memory type. | [`Convert.swift`](Sources/DataKit/Property/Convert.swift) |
| [`Custom`](#custom) | Drop into raw `ReadContainer` / `WriteContainer` access. | [`Custom.swift`](Sources/DataKit/Property/Custom.swift) |
| [`Using`](#using) | Branch on a value already in the context (e.g. feature flags, length prefixes). | [`Using.swift`](Sources/DataKit/Property/Using.swift) |
| [`Scope`](#scope) | Restrict checksum coverage / sub-buffer reads to a sub-range. | [`Scope.swift`](Sources/DataKit/Property/Scope.swift) |
| [`Environment`](#environment) | Read ambient state (endianness, suffix terminator, etc.) during the walk. | [`Environment/`](Sources/DataKit/Environment/) |
| [`Conversion` / `ReversibleConversion`](#conversion--reversibleconversion) | Reusable bidirectional encoders (UTF-8, prefix-count, etc.). | [`Conversions/`](Sources/DataKit/Conversions/) |
| [`ChecksumProperty`](#checksums) | CRC and custom checksum fields via [crc-swift](https://github.com/QuickBirdEng/crc-swift). | [`Checksum.swift`](Sources/DataKit/Property/Checksum.swift) |

### Property

`Property` wraps a key path so the compiler can resolve the root type, and is the
entry-point for the fluent `.conversion { ... }` / `.read(...)` / `.write(...)` modifiers
that ultimately build a `Convert` or `Custom`.

```swift
Property(\.id)
Property(\.payload).conversion { $0.exactly(UInt16.self) }
```

A bare key path (e.g. `\.id`) inside a builder is equivalent to `Property(\.id)`.

### Convert

`Convert` is the bridge between a model's Swift type and the wire's bytes. Three forms:
a `Conversion` builder, paired raw closures, or — for `ReadWritable` — a
`ReversibleConversion`.

```swift
Convert(\.string) {                       // C string: UTF-8, 0-terminated
    $0.encoded(.utf8).dynamicCount
}
.suffix(0 as UInt8)

Convert(\.length) {                       // Pascal short string
    $0.encoded(.ascii).prefixCount(UInt8.self)
}

Convert(\.humidity) {                     // Double <-> wire UInt8 (0...100)
    Double($0) / 100
} writing: {
    UInt8($0 * 100)
}
```

### Custom

`Custom` is the escape hatch for fields that no other primitive expresses. If the same
custom logic appears more than once, lift it into a reusable `Conversion`.

```swift
Custom(\.timestamp) { container in
    let raw = try UInt32(from: &container)
    return Date(timeIntervalSince1970: TimeInterval(raw))
} write: { container, date in
    try UInt32(date.timeIntervalSince1970).write(to: &container)
}
```

### Using

`Using` runs a sub-format that depends on a value already in the context (or already on
the root, during a write). The workhorse for feature-flag and length-prefixed layouts.

```swift
\.count                       // parse a count byte first
Using(\.count) { count in
    for index in 0..<count {
        \.items[index]
    }
}
```

### Scope

`Scope` restricts the "current data view" so that checksums and similar primitives
operate on the right region. `endInset` reserves trailing bytes for a value that follows
the scope (typically the checksum itself).

```swift
Scope(endInset: 4) {          // reserve 4 trailing bytes for the CRC
    \.header
    \.payload
}
CRC32.default                 // computed over the scope's bytes only
```

### Environment

Like SwiftUI's `@Environment`, but for binary formats. The format walk reads ambient
state from `EnvironmentValues` and modifiers like `.endianness(.big)` /
`.suffix(0 as UInt8)` / `.skipChecksumVerification()` scope changes to a subtree.

Built-in keys:

- `endianness` — default is `nil` (host-native). **Set this explicitly** for any wire
  protocol that must be portable.
- `suffix` — terminator bytes for variable-length sequences.
- `skipChecksumVerification` — read but do not validate.

Define your own keys by conforming to `EnvironmentKey` and extending `EnvironmentValues`,
the same way you would for SwiftUI.

### Conversion / ReversibleConversion

Reusable composable transforms used inside `Convert` and `Property.conversion(...)`.
`ReversibleConversion` bundles a forward and reverse direction for round-trippable types.

```swift
// Two takes on a length-prefixed UTF-8 string:

Convert(\.string) { $0.encoded(.utf8).prefixCount(UInt8.self) }   // 1-byte length prefix
Convert(\.string) { $0.encoded(.utf8).dynamicCount }              // read to terminator
    .suffix(0 as UInt8)
```

Other ready-to-use conversions: `.cast`, `.clamped`, `.exactly`, `.converted(to: UnitTemperature.celsius)`,
`.map`, `.at(keyPath)` — see [`Conversions/`](Sources/DataKit/Conversions/) for the full list.

### Checksums

Bare `Checksum` values (e.g. `CRC32.default`) inside a format builder read/verify on
decode and compute/append on encode — always in big-endian. The input range is the
container's `consumedData`; pair with `Scope` to control what's covered.

```swift
Scope {
    \.payload
    CRC32.default      // covers exactly the scoped bytes
}
```

For checksums whose value lives on the model itself, use `ChecksumProperty` with a
keyPath. Combine with `skipChecksumVerification` when reading captures that may be
corrupted.

## Built-in conformances

These are `ReadWritable` out of the box:

- All standard-library fixed-width integers (`Int`, `Int8`…`Int64`, `UInt`, `UInt8`…`UInt64`).
- `Float16` (arm64-only), `Float32`, `Float64`.
- `RawRepresentable` types whose `RawValue` is itself `ReadWritable` (the common case
  for integer-backed enums).
- `Optional<Wrapped>` where `Wrapped` is `ReadWritable`. **Note:** reading always
  produces `.some`; the `Optional` typing matters on the write side and for
  `ReadContext.readIfPresent(for:)`. To make presence truly optional on read, gate the
  read with `Using` and a flag.

All numeric encodings respect `EnvironmentValues.endianness`. The host-native default is
a footgun for cross-platform formats — set endianness explicitly at the top of your
format.

## Requirements

- Swift 5.9+
- iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+, Linux (Swift 5.9+)
- Single dependency: [crc-swift](https://github.com/QuickBirdEng/crc-swift) (re-exported
  as `CRC`)

Documentation is hosted at [Swift Package Index](https://swiftpackageindex.com/QuickBirdEng/DataKit/documentation).

## Contributing

Issues and PRs welcome. Before opening a PR:

- Run `swift test` from the repo root — all existing tests should pass.
- Add a round-trip test for any new format primitive or built-in conformance.
- See [`CLAUDE.md`](CLAUDE.md) for an architecture tour.

## License

DataKit is released under the MIT license. See [LICENSE](LICENSE).

## Author

DataKit is created with ❤️ by [QuickBird](https://quickbirdstudios.com).
