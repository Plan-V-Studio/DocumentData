# Document Data

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FPlan-V-Studio%2FDocumentData%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Plan-V-Studio/DocumentData)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FPlan-V-Studio%2FDocumentData%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Plan-V-Studio/DocumentData)

![GitHub License](https://img.shields.io/github/license/Plan-V-Studio/DocumentData)
![GitHub Release](https://img.shields.io/github/v/release/Plan-V-Studio/DocumentData)


A data persistence library like SwiftData, and persist all the data into Property List Document.

## Setup

First, you need to add this library to your project by using [Swift Package Manager](https://github.com/apple/swift-package-manager). Open your Xcode, go to File > Add Package Dependencies... Then, copy https://github.com/Plan-V-Studio/DocumentData to the search bar, choose the first library and configure your updating method.

If you are using Swift Package, add the code below to your dependencies in `Package.swift` file.

```swift
.package(url: "https://github.com/Plan-V-Studio", branch: "main")
```

## Quick Start

To use Document Data, you need to create your data model first. This is an example for create a model to storing user's data.

```swift
class UserData {
    var username: String
    var password: Data
    var universalID: UUID
}
```

Then, add `@PersistedModel` macro before the class declaration.

```swift
@PersistedModel
class UserData {
  // ...
}
```

`@PersistedModel` macro will automatically convert this data model to a persistence data model, and store `UserData.storage.plist` file in `/Container/Application Support/` of your app.

> [!TIP]
>
> Persisence file's name will autimatically use its data model's name,
> to customize you model name, download documentation in release page.

## Documentation

Document Data use DocC to generate documentation, you can download compiled document in [release page](https://github.com/Plan-V-Studio/DocumentData/releases).

## Statememt

**This is beta software, which means that none of the features and methods of the library have been systematically tested. Plan-V Studio will not be responsible for any direct or indirect loss caused by your use of this library.**
