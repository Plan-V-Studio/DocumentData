# How Can Persistence File Work?

Explanation of the backing data modeling in DocumentData.

## Overview

Persistence file is the basic backing component of DocumentData, this article explain that how can DocumentData work.

### Data Container

DocumentData use Apple Property List as the container to persist
and modeling data, each model will individually storing in 
`.storage.plist` file in their `Application Support` folder. 
Basically, DocumentData persistence file is a property list.

For every model, a contant named `_$persistedDocumentName` 
will be generate to make sure the persistence document name is fixed.

`_$persistedDocumentName` default generated based on class name, ``StorageName()`` can change this default behavior and customize persistence document name.

### Read and Write

When you read any property, the getter of this property will call the function `access(_:)` in the expanded code. 
`access(_:)` will read persistence file and return the underlined version's value.

- Note: Underlined version's property is the plain value property, this property will help persistence file encoding and decoding data.

When you change the value of any property, 
the property setter will change the underlined property value and call `save()` function the write all the model the the persistence file.

**Implementation of `access(_:)` function**

```swift
func access<T>(_ keyPath: KeyPath<\(raw: decl.name.text), T>) -> T where T: Codable {
    let container = Foundation.URL(filePath: Foundation.NSHomeDirectory())
        .appending(component: "Library")
        .appending(component: "Application Support")
        .appending(component: _$persistedDocumentName)

    // This function will be called when the persistence file
    // is not found to prevent an error in the next operation.
    if !Foundation.FileManager.default.fileExists(atPath: container.path(percentEncoded: false)) {
        self.save()
    }
    
    // Read the persistence file.
    let data = try! Data(contentsOf: container)
    
    let decoder = Foundation.PropertyListDecoder()
    
    // decode the file, then return the specified value.
    let decoded = try! decoder.decode(\(raw: decl.name.text).self, from: data)
    return decoded[keyPath: keyPath]
}
```

**Implementation of `save()` function**

```swift
func save() {
    let container = Foundation.URL(filePath: NSHomeDirectory())
        .appending(component: "Library")
        .appending(component: "Application Support")
        .appending(component: _$persistedDocumentName)

    let encoder = PropertyListEncoder()
    encoder.outputFormat = .binary
    
    // Write model to persistence file.
    let encoded = try! encoder.encode(self)
    try! encoded.write(to: container)
}
```

## Examples

This is am example for a persistence model and it's relative preperty list structure.
```swift
@PersistedModel
class SomeModel {
    var string: String
    var bool: Bool
    @PersistedIgnore
    var bool2: Bool

    init(string: String, bool: Bool, bool2: Bool) {
        self.string = string
        self.bool = bool
        self.bool2 = bool2
    }
}

SomeModel(string: "hello", bool: false, bool2: true)
```

```xml
<!--SomeModel.storage.plist-->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>string</key>
    <string>hello</string>
    <key>bool</key>
    <false/>
</dict>
</plist>

```

As you can see, `bool2` isn't persist because it marked `@PersistedIgnored`.
