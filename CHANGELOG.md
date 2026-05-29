# Changelog

All notable changes to DataKit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
While the major version is `0`, breaking changes are released as minor version bumps.

## [Unreleased]

_Nothing yet._

## [0.2.0] - 2026-05-29

First release of the modernized DataKit. This is a maintenance-focused release: no new
format features, but a significant pass over packaging, documentation, and Swift
concurrency support. It contains source-breaking changes — see
[Migrating to 0.2.0](Sources/DataKit/DataKit.docc/Migrating-to-0.2.0.md) for a guided
upgrade.

### Added

- **Full Swift Concurrency support.** The public API now conforms to `Sendable`, so
  formats, conversions, and values can be shared across actor and task boundaries.
- **Documentation.** Every public symbol now carries a `///` doc comment, and a DocC
  catalog (`DataKit.docc`) introduces the two-phase read model, the environment system,
  and the conversion pipeline. Hosted documentation is available on the
  [Swift Package Index](https://swiftpackageindex.com/QuickBirdEng/DataKit/documentation).
- **Declared platforms.** `Package.swift` now declares minimum platforms explicitly:
  iOS 13, macOS 10.15, tvOS 13, watchOS 6.
- **Continuous integration.** A GitHub Actions workflow builds and tests on macOS and
  Linux.
- **`.spi.yml`** so the Swift Package Index builds and hosts the DocC documentation.
- **`NOTES.md`** tracking candidate future features (error context enrichment, `Bounded`,
  `BitField`, a `DataKitTesting` target, additional conversions).

### Changed

- **Swift tools version raised from 5.4 to 5.10.** 5.4 could not actually compile the
  result-builder code (`buildPartialBlock` requires 5.7); 5.10 is the supported floor and
  enables checked `Sendable` conformances on key-path-backed types.
- The library target enables the `StrictConcurrency` and `ExistentialAny` upcoming
  features.
- The README has been restructured for approachability: a quick-start example up front, a
  concepts reference, and an explicit requirements section.

### Fixed

- **`skipChecksumVerification` is now honored.** `ChecksumProperty` previously read the
  environment value but never consulted it, so checksums were always verified even when
  verification had been disabled. The flag now correctly suppresses verification while
  still consuming the checksum bytes.
- Corrected the broken `crc-swift` repository link in the README (`crc-swift.org` →
  `crc-swift`).

### Removed

- **`CannotWriteNilError`.** This error type was declared publicly but never thrown
  anywhere in the library. (Breaking only for code that referenced the type by name.)

### Breaking Changes

These require source changes in dependent code. See
[Migrating to 0.2.0](Sources/DataKit/DataKit.docc/Migrating-to-0.2.0.md) for details and
fixes.

- Conforming types of `Readable`, `Writable`, and `ReadWritable` must now be `Sendable`.
  All standard-library conformers already satisfy this.
- `FormatProperty` — and therefore `ReadableProperty` and `WritableProperty` — now refine
  `Sendable`; their `Root` must be `Sendable`.
- Closures passed to `Custom` and `Convert` (and the fluent `Property.read`/`.write`/
  `.converted` helpers) must now be `@Sendable`.
- `Checksum` types used inside a format must be `Sendable`.
- `KeyPath` no longer conforms to `FormatProperty` / `ReadableProperty` /
  `WritableProperty` directly. Bare key-path syntax (`\.field`) inside a format builder
  still works; passing a key path where a `FormatProperty` is expected **outside** a
  builder now requires wrapping it explicitly as `Property(\.field)`.
- Minimum Swift toolchain is now 5.10 (previously declared 5.4).

## [0.1.1] - 2024-03-14

### Fixed

- Bumped `crc-swift` to 0.1.1.
- Fixed a compilation issue on x86_64 hardware.

## [0.1.0]

- Initial public release.

[Unreleased]: https://github.com/QuickBirdEng/DataKit/compare/0.2.0...HEAD
[0.2.0]: https://github.com/QuickBirdEng/DataKit/compare/0.1.1...0.2.0
[0.1.1]: https://github.com/QuickBirdEng/DataKit/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/QuickBirdEng/DataKit/releases/tag/0.1.0
