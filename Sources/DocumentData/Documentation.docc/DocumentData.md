# ``DocumentData``

A data persistence library like SwiftData, can persist all the data into Property List Document.

@Metadata {
    @DisplayName("Document Data")
    @PageColor(yellow)
    @SupportedLanguage(swift)
    
    @Available(macOS, introduced: "14.0")
    @Available(iOS, introduced: "17.0")
    @Available(watchOS, introduced: "10.0")
    @Available(tvOS, introduced: "17.0")
    @Available(macCatalyst, introduced: "17.0")
    @Available(visionOS, introduced: "1.0")
}

## Overview

DocumentData allows you to persist your data into a Property List
file and store it in the `/Library/Application Support` folder
of your application Container.

## Topics

### Essentials

- <doc:CreateAPersistenceModel>

### Principle of Realization

- <doc:HowCanPersistenceFileWork>
- <doc:MacroExpansionAnalysis>

### Macros

- ``PersistedModel()``
- ``PersistedIgnored()``
- ``PersistedProperty()``

### Customize Your Model

- ``StorageName()``
- ``ModelCodingKey()``
