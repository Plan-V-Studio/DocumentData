# Macro Expansion Analysis

How the DocumentData library macros expand.

## Overview

In this article, well will talk about the macro expansions.

### Expansion of @PersistedModel

``PersistedModel()`` can convert a class to a persistence model.

This is some members that ``PersistedModel()`` will generate:

|Member Name|Usage|Code Template|
|-|-|-|
|`\_$observationRegistrar`|Conform to Observation, allows class to be observed.|<doc:CodeTemplate#$observationRegistrar>
|`_$persistedDocumentName`|Persistence file's name.|<doc:CodeTemplate#$persistedDocumentName>|
|`_$PersistedCodingKeys`|Coding keys that use to encode and decode.|<doc:CodeTemplate#$PersistedCodingKeys>|
|`init(from:)`|Decodable requirement.|<doc:CodeTemplate#init(from)>|
|`encode(to:)`|Encodable requirement.|<doc:CodeTemplate#encode(to)>|
|`access(_:)`|Access a specific value in persistence file.|<doc:CodeTemplate#access()>|
|`save()`|Save model datas to persistence file.|<doc:CodeTemplate#save()>|
|`access(keyPath:)`| Convenience implementation of `ObservationRegistrar.access(\_:keyPath:)`|<doc:CodeTemplate#access(keyPath)>|
|`withMutation(keyPath:_:)`|Convenience implementation of `ObservationRegistrar.withMutation(of:keyPath:_:)`|<doc:CodeTemplate#withMutation(keyPath)>|

For each variable property in class, ``PersistedModel()`` macro will attach them a ``PersistedProperty()`` macro, unless it marked with ``PersistedIgnored()`` or ``StorageName()``.

``PersistedModel()`` will automatically make class conforms to `Encodable`, `Decodable` and `Observable`.

### Expansion of @PersistedProperty

``PersistedProperty()`` will automatically managed by ``PersistedModel()``.

For current property, ``PersistedModel()`` will generate this methods below

|Method Name|Code Template|
|-|-|
|`init`|<doc:CodeTemplate#init>|
|`get`|<doc:CodeTemplate#get>|
|`set`|<doc:CodeTemplate#set>|

By the way, ``PersistedProperty()`` will also generate a peer property with slash. 

### Expansion of @PersistedIgnored

``PersistedIgnored()`` will make a property observable but not persisted.

The methods will generate are **very similar** with ``PersistedProperty()`` generated, but have no persistece commands. For details, view <doc:CodeTemplate>.

### Expansion of @ModelCodingKey

``ModelCodingKey()`` will generate a `_$PersistedCodingKeys` enumrate property that can replace the default behavior of ``PersistedModel()``'s expansion, 
and generate a `_$PersistedCodingKeys` property which based on user's customize.
