# ``DocumentData``

A data persistence library like SwiftData, and persist all the data into Property List Document.

@Metadata {
    @DisplayName("Document Data")
    @PageColor(yellow)
    @SupportedLanguage(swift)
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
