# Document Data

A data persistence library like SwiftData, and persist all the data into Property List Document.

## Setup

First, you need to add this library to your project by using [Swift Package Manager](https://github.com/apple/swift-package-manager). Open your Xcode, go to File > Add Package Dependencies...

If you are using Swift Package, add the code below to your dependencies in `Pacakage.swift` file.

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
