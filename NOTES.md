# Feature ideas

Drafts of feature ideas surfaced during the 2026 audit. Each entry is sized for a single
GitHub issue when there is appetite to act on it. None of these are committed work — the
audit explicitly scoped this maintenance pass to docs, packaging, README, and Sendable.

## 1. Error context enrichment

**What.** Wrap thrown errors at every `FormatProperty` boundary with the current byte
offset, the `Scope`/`Using`/`KeyPath` breadcrumb path, and a reference to the underlying
error. Surface as a public `DataKitError` struct with `.byteOffset`, `.path`, and
`.underlyingError`. Today errors like `LengthExceededError`, `ConversionError`, and
`ReadContext.ValueDoesNotExistError` are positionless — almost useless for debugging a
real-world wire-protocol failure on byte 47 of a 200-byte packet.

**Sketch.**
```swift
do {
    let v = try Packet(data)
} catch let error as DataKitError {
    print(error.byteOffset)      // 47
    print(error.path)            // "Packet.payload -> Scope -> Convert(\.temperature)"
    throw error.underlyingError  // the original LengthExceededError
}
```

**Feasibility.** Medium. Every existing `FormatProperty` site that throws must be
touched. Risk of double-wrapping when errors propagate through several layers; add an
"already enriched" check. No public-API breakage.

**Prior art.** `construct.py` `ConstructError.stream_position`,
`swift-binary-parsing.ParsingError.location`.

## 2. `Bounded` / `FixedLength` sub-format

**What.** Run a child format inside an explicit byte budget. On read, assert the child
consumed *exactly* N bytes (or pad with a fill byte if `mode: .padding`). On write,
assert the child produced N (or pad). Builds directly on `Scope` — most of the read-side
code already exists there.

**Sketch.**
```swift
Bounded(length: 16, padding: 0x00) {
    Convert(\.name) { $0.encoded(.utf8).dynamicCount }
        .suffix(0 as UInt8, isRequired: false)
}

// Or length read from another keyPath:
\.payloadLength
Bounded(length: \.payloadLength) {
    \.payload
}
```

**Feasibility.** Easy. ~80% of the implementation is already in
`Sources/DataKit/Property/Scope.swift` — just add an `expectedLength: Int?` and
post-check `container.index` movement.

**Prior art.** Kaitai Struct `size:`; construct.py `FixedSized` / `Padded`.

## 3. `BitField` / `Bits` primitive

**What.** Open a "bit cursor" inside the byte stream and read/write N-bit fields. Today
the only sub-byte expression is an `OptionSet`, which works only for one-bit-per-field
boolean flags. Real protocols (BLE, IPv4 header, H.264 NALU, MIDI) regularly pack
multi-bit fields into one byte.

**Sketch.**
```swift
BitField {                                // consumes whole bytes; must end byte-aligned
    Bits(\.version, width: 4)             // top nibble
    Bits(\.headerLength, width: 4)
    Bits(\.dscp, width: 6)
    Bits(\.ecn, width: 2)
}
.bitOrder(.msbFirst)
```

**Feasibility.** Medium. Needs `BitReadContainer` / `BitWriteContainer` wrappers and a
decision on MSB-first vs LSB-first bit order. Hardest design choice: error vs pad when a
block doesn't end on a byte boundary. No existing-code rewrites.

**Prior art.** Kaitai `b3`, `b13`; construct.py `BitStruct` / `BitsInteger`.

## 4. `DataKitTesting` round-trip helpers (new target)

**What.** A `DataKitTesting` library target shipping `assertRoundTrip(_:bytes:)` and a
diff-friendly hex-dump on failure. The round-trip invariant is the central correctness
contract of `ReadWritable`; every consumer reinvents this same test today.

**Sketch.**
```swift
import DataKitTesting

func testWeatherPacketRoundTrip() throws {
    try assertRoundTrip(
        WeatherStationUpdate(features: [.hasTemperature], ...),
        bytes: [0x02, 0x01, 0x42, ...]
    )
}
```

**Feasibility.** Easy. Mostly: write, read back, compare; re-write, compare bytes. New
target in `Package.swift` so it doesn't bloat the runtime library.

**Prior art.** Pattern is widely used (`swift-snapshot-testing` philosophy,
QuickCheck-style property tests).

## 5. More conversions: LEB128, ZigZag varint, Q-format, half-float

**What.** Add the obvious missing numeric encodings to `Sources/DataKit/Conversions/`:

- LEB128 / ULEB128 (DWARF, Wasm, Protocol Buffers varints).
- ZigZag int↔uint (Protobuf `sint32` / `sint64`).
- Q-format fixed-point (Q15.16, Q7.8, etc. — DSP/audio/BLE).
- ASN.1 BER length octets (LDAP, SNMP, TLS certs).

`Float16` is already a `ReadWritable` conformance on arm64; consider a software fallback
for x86_64 if there is demand.

**Feasibility.** Easy each, but LEB128's variable byte count on write needs care. Same
pattern as `Conversion+PrefixCount.swift`. Can be shipped one PR at a time.

**Prior art.** Every binary-protocol library ships varints; Foundation does not.

---

## Out-of-scope ideas mentioned in the audit but not pursued

- **Async streaming reads** from `AsyncSequence<UInt8>` / `InputStream`. Hard — collides
  with random-access-data assumptions in `Scope` and `Checksum`. Defer until concrete
  demand.
- **`@ReadWritable` macro** that synthesizes `format` + `init(from:)` from declared
  properties. Substantial implementation effort; worth reconsidering once Apple's
  `swift-binary-parsing` story shakes out.
- **`OneOf` discriminated-union primitive.** Useful for TLV-style protocols but requires
  a non-trivial type-erasure design.
- **Hex-dump / debug pretty-printer.** Strong UX win, but depends on the error-context
  feature (#1) for the field-to-byte mapping.
