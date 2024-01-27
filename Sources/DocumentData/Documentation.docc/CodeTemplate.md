# Code Templates

Expanded code examples.

## Overview

`<#XXX#>` is defined for replaceable strings.

## @PersistedModel Examples

### \_$observationRegistrar

```swift
private let _$observationRegistrar = Observation.ObservationRegistrar()
```

### \_$persistedDocumentName

As default:

```swift
private let _$persistedDocumentName = "<#CLASS NAME#>.storage.plist"
```

Used ``StorageName()``:

```swift
private let _$persistedDocumentName = "<#CUSTOM NAME#>.storage.plist"
```

### \_$PersistedCodingKeys

```swift
enum _$PersistedCodingKeys: String, Codable {
    case _<#PROPERTY NAME#> = <#PROPERTY NAME#>
    ...
}
```

### encode(to:)

```swift
func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: _$PersistedCodingKeys.self)
    try container.encode(_<#PROPERTY NAME#>, forKey: ._<#PROPERTY NAME#>)
    ...
}
```

### init(from:)

```swift
required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: _$PersistedCodingKeys.self)
    self._<#PROPERTY NAME#> = try container.decode(<#PROPERTY TYPE#>.self, forKey: ._<#PROPERTY NAME#>)
    ...
}
```

### access(\_:)

```swift
func access<T>(_ keyPath: KeyPath<<#CLASS NAME#>, T>) -> T where T: Codable {
    let container = Foundation.URL(filePath: Foundation.NSHomeDirectory())
        .appending(component: "Library")
        .appending(component: "Application Support")
        .appending(component: _$persistedDocumentName)

    if !Foundation.FileManager.default.fileExists(atPath: container.path(percentEncoded: false)) {
        self.save()
    }
    
    let data = try! Data(contentsOf: container)
    
    let decoder = Foundation.PropertyListDecoder()
    
    let decoded = try! decoder.decode(<#CLASS NAME#>.self, from: data)
    return decoded[keyPath: keyPath]
}
```

### save()

```swift
func save() {
    let container = Foundation.URL(filePath: NSHomeDirectory())
        .appending(component: "Library")
        .appending(component: "Application Support")
        .appending(component: _$persistedDocumentName)

    let encoder = PropertyListEncoder()
    encoder.outputFormat = .binary
    
    let encoded = try! encoder.encode(self)
    try! encoded.write(to: container)
}
```

### access(keyPath:)

```swift
internal nonisolated func access<Member>(
    keyPath: KeyPath<<#CLASS NAME#>, Member>
) {
    _$observationRegistrar.access(self, keyPath: keyPath)
}
```
### withMutation(keyPath:\_:)

```swift
internal nonisolated func withMutation<Member, MutationResult>(
    keyPath: KeyPath<<#CLASS NAME#>, Member>,
    _ mutation: () throws -> MutationResult
) rethrows -> MutationResult {
    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
}
```

### default

```swift
static var `default`: Self {
    let container = Foundation.URL(filePath: Foundation.NSHomeDirectory())
        .appending(component: "Library")
        .appending(component: "Application Support")
        .appending(component: _$persistedDocumentName)
    let data = try! Data(contentsOf: container)
    let decoder = Foundation.PropertyListDecoder()
    return try! decoder.decode(<#CLASS NAME#>.self, from: data)
}
```

### isPersisted

```swift
static var isPersisted: Bool {
    let container = Foundation.URL(filePath: Foundation.NSHomeDirectory())
        .appending(component: "Library")
        .appending(component: "Application Support")
        .appending(component: _$persistedDocumentName)
    let fileManager = Foundation.FileManager()
    return fileManager.fileExists(atPath: container.path(percentEncoded: false))
}
```

## @PersistedProperty Examples

### init

```swift
@storageRestrictions(initializes: _<#PROPERTY NAME#>)
init {
    _<#PROPERTY NAME#> = newValue
}
```

### get

```swift
get {
    access(keyPath: \.<#PROPERTY NAME#>)
    return access(\._<#PROPERTY NAME#>)
}
```

### set

```swift
set {
    withMutation(keyPath: \.<PROPERTY NAME>) {
        _<#PROPERTY NAME#> = newValue
        self.save()
    }
}
```

### Peer Property

```swift
var _<#PROPERTY NAME#>: <#PROPERTY TYPE#>
```

## @PersistedIgnored Examples

### init

```swift
@storageRestrictions(initializes: _<#PROPERTY NAME#>)
init {
    _<#PROPERTY NAME#> = newValue
}
```

### get

```swift
get {
    access(keyPath: \.<#PROPERTY NAME#>)
    return _<#PROPERTY NAME#>
}
```

### set

```swift
set {
    withMutation(keyPath: \.<PROPERTY NAME>) {
        _<#PROPERTY NAME#> = newValue
    }
}
```

### Peer Property

```swift
var _<#PROPERTY NAME#>: <#PROPERTY TYPE#>
```

## @StorageName Examples

### Peer Property

```swift
@_PersistedIgnored private static let _$persistedDocumentName = "<#Initializer Value#>.storage.plist"
```
