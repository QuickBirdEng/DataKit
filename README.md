
![DataKit](https://github.com/QuickBirdEng/DataKit/assets/15239005/43e7a29d-ae9e-4fb2-8f82-3b9f31c6c254)

DataKit offers a modern, intuitive and declarative interface for reading and writing binary formatted data in Swift. 

## 🏃‍♂️Getting started

As an introduction into how this library can be used to make working with binary formatted data easier, let me first introduce you to the type, we are going to read/write. Let's assume we are building a weather station and we are using the following type(s) to give updates about the currently measured values:

```swift
struct WeatherStationFeatures: OptionSet, ReadWritable {
    var rawValue: UInt8

    static var hasTemperature = Self(rawValue: 1 << 0)
    static var hasHumidity = Self(rawValue: 1 << 1)
    static var usesMetricUnits = Self(rawValue: 1 << 2)
}

struct WeatherStationUpdate {

    var features: WeatherStationFeatures
    var temperature: Measurement<UnitTemperature>
    var humidity: Double

}
```

The encoded format should be:
- Each message starts with a byte with the value 0x02.
- The following byte contains multiple feature flags:
    -> bit 0 is set: Using °C instead of °F for the temperature
    -> bit 1 is set: The message contains temperature information
    -> bit 2 is set: The message contains humidity information
- Temperature as a big-endian 32-bit floating-point number
- Relative Humidity as UInt8 in the range of [0, 100]
- CRC-32 with the default polynomial for the whole message (incl. 0x02 prefix).

### Writing data

You have two options for converting the above type `WeatherStationUpdate` into data: A `DataBuilder` or the `Writable` protocol. If you intend to both read and write the data - make sure to read the `Reading & Writing data` section

#### DataBuilder

A `DataBuilder` provides you with a very simple and limited interface. Using the power of result builders, you can simply state the values to be written in a given order and `DataBuilder` will take over all the work to encode the values and append the individual bytes to form a `Data` object. `DataBuilder` is always expected to return a `Data` object without throwing errors, which is why conversion are not supported here - You might want to have a look at the `Writable` protocol then!

```swift
extension WeatherStationUpdate {

    @DataBuilder var data: Data {
        UInt8(0x02)
        features
        if features.contains(.hasTemperature) {
            Float(temperature.converted(to: features.contains(.usesMetricUnits) ? .celsius : .fahrenheit).value)
        }
        if features.contains(.hasHumidity) {
            UInt8(humidity * 100)
        }
        CRC32.default
    }

}
```

With this addition, you can easily get the data of this object using its `data` property.

#### Writable

With the power of keyPaths and result builders, you can also write your objects into `Data` using the `Writable` protocol and its `writeFormat` property. Simply state out individual fixed values (e.g. byte prefixes), keyPaths with `Writable` values or other constructs that are further explained in the `Extras` section of this document.

```swift
extension WeatherStationUpdate: Writable {

    static var writeFormat: WriteFormat {
        Scope {
            UInt8(0x02)

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

            CRC32.default
        }
        .endianness(.big)
    }

}
``` 

By conforming to the `Writable` protocol, you are now able to simply call its `write` function to write its data out:

```swift
let message: WeatherStationUpdate = ...
let messageData = try message.write() // You can also inject a custom environment here, if needed
```

### Reading data

Supporting reading of data into objects is slightly more complicated. Conforming to the `Readable` protocol will require you to implement both an initializer to create an object from a given `ReadContext` and a static `readFormat` property describing how data is aligned.

A `ReadContext` provides you with the values that have been read using the `readFormat`. Make sure to use the same keyPaths in the initializer and `readFormat` to ensure smooth reading of values.

```swift
extension WeatherStationUpdate: Readable {

    init(from context: ReadContext<WeatherStationUpdate>) throws {
        features = try context.read(for: \.features)
        temperature = try context.readIfPresent(for: \.temperature) ?? .init(value: .nan, unit: .kelvin)
        humidity = try context.readIfPresent(for: \.humidity) ?? .nan
    }

    static var readFormat: ReadFormat {
        Scope {
            UInt8(0x02)

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

            CRC32.default
        }
        .endianness(.big)
    }

}
``` 

By implementing all these requirements of the `Readable` protocol, you now gain another initializer `init(_: Data) throws` to read objects from `Data` objects:

```swift
let data: Data = ...
let message = try WeatherStationUpdate(data) // You can also inject a custom environment here, if needed
```

### Reading & Writing data

To make a type both `Readable` and `Writable`, you can conform your type to the `ReadWritable` protocol. Instead of providing a separate format for reading and writing, you can define a `Format` property that is used for both reading and writing. For our example type, we can simply merge the two formats into one and provide the initializer for creating an object from a given `ReadContext`.

```swift
extension WeatherStationUpdate: ReadWritable {

    init(from context: ReadContext<WeatherStationUpdate>) throws {
        features = try context.read(for: \.features)
        temperature = try context.readIfPresent(for: \.temperature) ?? .init(value: .nan, unit: .kelvin)
        humidity = try context.readIfPresent(for: \.humidity) ?? .nan
    }
    
    static var format: Format {
        Scope {
            UInt8(0x02)

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

            CRC32.default
        }
        .endianness(.big)
    }

}
```

Hooray, you can now read and write your objects! 🎉

## 🤸‍♂️ Extras

Reading/Writing data is often quite complicated and different format pose different challenges to minimize payloads, reduce bandwidth, improve performance, etc. To make it easy to handle different common scenarios, `DataKit` provides a couple of extra features to handle the most common challenges.

### ✏️ Convert / Custom / Property

In some special cases, you might need more control over how data is read/written. For these cases, the wrappers `Custom`, `Convert` and `Property` might be of interest.

- `Property` makes it easy to wrap a keyPath, if the Root type may not be recognized by the compiler. You can further use functions on it to map a `Property` to either a `Custom` or `Convert` wrapper.
- `Convert` allows you to convert a keyPath's value before reading/writing it. Oftentimes, this is very usefuly for sequence values with variable size. You can either provide custom conversion methods directly or use a pre-existing `Conversion`/`ReversibleConversion` value.
- `Custom` allows you to access the raw reading/writing functionality with direct access to the `ReadContainer`/`WriteContainer` and respective context values. If you need the read/write behavior more than once in your codebase, you might want to have a look at conversions though.

### 💱 Conversion / ReversibleConversion

For some types, there is not a single "correct" format (e.g. thinking about Pascal vs C strings), which is why `DataKit` uses so called `Conversion` values to allow for conversion to be defined once and then used multiple times. Especially helpful is the `ReversibleConversion` type that allows for conversion to be provided in both directions at the same time.

Assuming our type has a `\.string` keyPath with a `String` value, you could either use a suffix 0-byte to encode the string using UTF8 (similar to C strings):
```swift
Convert(\.string) { // UTF8 string with a suffix 0-byte
    $0.encoded(.utf8).dynamicCount
}
.suffix(0 as UInt8)
```

Or you encode the string with a prefix byte containing the byte count (similar to Pascal ShortString):
```swift
Convert(\.string) { // Ascii string with a prefix count byte
    $0.encoded(.ascii).prefixCount(UInt8.self)
}
```

There are many more conversion available, e.g. for converting between integer/floating-point types, making it easy to convert directly to your preferred types without the need of converting yourself.

### 🤓 Using

With a `Using` construct, you can access values from the `ReadContext` or the value to be written. `Using` can be very helpful, if values in the data itself depend on each other or how individual values need to be read or written.

### Environment

Similar to SwiftUI's environment, you can also modify the behavior of individual components in `DataKit` using the `Environment`.
You can modify the environment when starting the reading/writing process or using modifiers inside the readFormat/writeFormat/format-properties.
To access environment values, you may want to have a look at the `Environment` type to be used in one of the format builders - or for more direct access both `ReadContainer` and `WriteContainer` have a `environment` property.

Here are some modifiers, you might want to use:

- `endianness`: By default, `DataKit` reads & writes values in the endianness of the current machine (except for CRCs, where big-endian is used). If your protocol requires a different endianness, make sure to specify a concrete one.
- `skipChecksumVerification`: If you want to have a CRC to be created when writing out data, but ignore an incorrect checksum value when reading, you can set this property to `true` - by default `false` is used. Read the `Checksums` section for more information.
- `suffix`: For values with dynamic count (e.g. a sequence of values with a 0-suffix-byte), you can specify a `.dynamicCount` conversion on a given property. The specified value will stop the reading process of a given value and the value will be written out after the given sequence's end is encountered.

Feel free to add your own environment values using the `EnvironnentKey` protocol and an extension to the `EnvironmentValues` struct (very similar to SwiftUI).

### 🚧 Scope 

Some constructs (e.g. CRC checksums) make assumptions about the data as a whole and not only the part where the specific value is read/written. By using `Scope`, you can limit that data context to where it is individually placed. 

As an example, let's assume our `WeatherStationUpdate` is supposed to ignore the prefix `0x02` byte for the checksum calculation. We could simply exclude it from the scope:

```swift
static var format: Format {
    UInt8(0x02)
    
    Scope {
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

        CRC32.default
    }
    .endianness(.big)
}
```

With this change in place, the CRC will only be verified on the Scope itself and the prefix byte is ignored!

### ✅ Checksums

`DataKit`'s dependency [`crc-swift`](https://github.com/QuickBirdEng/crc-swift.org) provides CRC checksums and and easy-to-conform protocol for your own custom checksum values.

You may simply specify the checksum value itself inside one of the format builders. Alternatively, use a `ChecksumProperty` with a keyPath, so that you can store checksums in properties and write custom checksums from properties. In combination to the `skipChecksumVerification` environment value, you can also verify the checksum at a later stage for example.

## 🛠 Installation

`DataKit` currently only supports Swift package manager.

#### Swift Package Manager

See [this WWDC presentation](https://developer.apple.com/videos/play/wwdc2019/408/) about more information how to adopt Swift packages in your app.

Specify `https://github.com/QuickBirdEng/DataKit.git` as the package link.

#### Manually

If you prefer not to use a dependency manager, you can integrate DataKit into your project manually by downloading the source code and placing the files in your project directory.  

## 👤 Author

DataKit is created with ❤️ by [QuickBird](https://quickbirdstudios.com).

## ❤️ Contributing

Feel free to open issues for help, found bugs or to discuss new feature requests. Happy to help!
Open a pull request, if you want to propose changes to DataKit.

## 📃 License

DataKit is released under an MIT license. See [License.md](https://github.com/QuickBirdEng/DataKit/blob/master/LICENSE) for more information.
