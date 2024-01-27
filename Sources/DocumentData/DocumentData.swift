// The Swift Programming Language
// https://docs.swift.org/swift-book

import Observation

/// Convert a Swift class into a stored model that's managed by DocumentData.
///
/// Attach `@PersistedModel` to any Swift class that you want to defind it to model.
/// This is an example to create a persistence model.
/// ```swift
/// @PersistedModel
/// class UserInformation {
///     var username: String
///     var password: Data
///
///     init(username: String, password: Data) {
///         self.username = username
///         self.password = password
///     }
/// }
/// ```
///
/// You can use ``DocumentPersistedModel/default`` to get the current persistent data after the data has been stored once.
///
/// ```swift
/// let information = UserInformation.default
/// ```
///
/// If you want to ignore some property, attach model ``PersistedIgnored()`` to the property.
/// DocumentData will not persist ingored property to the storage.
@attached(
    member,
    names:
        named(_$observationRegistrar),
        named(_$persistedDocumentName),
        named(_$PersistedCodingKeys),
        named(init),
        named(encode),
        named(access),
        named(save),
        named(withMutation),
        named(`default`),
        named(isPersisted),
        named(url)
)
@attached(memberAttribute)
@attached(extension, conformances: Observable, Codable, DocumentPersistedModel)
public macro PersistedModel() = #externalMacro(module: "DocumentDataMacros", type: "PersistedModelMacro")

/// Convert a variable to DocumentData tracked.
///
/// - Important: Always attach macro ``PersistedModel()`` on it relative class to automoatically manage this macro.
///
/// ### See Also
/// - ``PersistedModel()``
@attached(accessor, names: named(init), named(get), named(set))
@attached(peer, names: prefixed(`_`))
public macro PersistedProperty() = #externalMacro(module: "DocumentDataMacros", type: "PersistedPropertyMacro")

/// Ignoring the persistence of the attached variable.
@attached(peer, names: prefixed(`_`))
@attached(accessor, names: named(init), named(get), named(set))
public macro PersistedIgnored() = #externalMacro(module: "DocumentDataMacros", type: "ObservationPersistedIgnoredMacro")

@attached(peer)
public macro _PersistedIgnored() = #externalMacro(module: "DocumentDataMacros", type: "PersistedIgnoredMacro")

/// Make current propety as the name of persistence file.
///
/// This macro can allow you change the default persistence filename. For example, I have a model names with `UserScheme`.
///
/// ```swift
/// @PersistedModel
/// class UserScheme {
///     // persisted properties
/// }
/// ```
///
/// This model should be named `UserScheme.storage.plist` by default. But I want to change my persistence file name to `Default.storage.plist`. I just need to do like this,
///
/// - Tip: Variable names are not fixed.
/// You can use any variable name as the name of the persistence file,
/// but you must provide a default value.
///
/// ```swift
/// @PersistedModel
/// class UserScheme {
///     // persisted properties
///     @StorageName
///     static let storageName = "Default"
/// }
/// ```
/// - Important: Never initialize this value, because the initial value will not change this persistence file name. For more detail, see <doc:HowCanPersistenceFileWork>
/// - Warning: ``StorageName()`` can only applied on `static let` property.
///
@attached(peer, names: named(_$persistedDocumentName))
public macro StorageName() = #externalMacro(module: "DocumentDataMacros", type: "StorageNameMacro")

