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
        named(url),
        named(delete),
        named(migrate),
        named(_$MigrationMiddleware),
        named(shouldMigrate)
)
@attached(memberAttribute)
@attached(extension, conformances: Observable, Codable, DocumentPersistedModel, Migratable)
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

/// Make current property as the coding keys fo persistence file.
///
/// This macro allow you customize the default coding keys. This is a example for model names with `UserProfile`.
///
/// ```swift
/// @PersistedModel
/// final class UserProfile {
///     var username: String
///     var password: Data
/// }
/// ```
///
/// The default coding key should be like this:
///
/// ```swift
/// enum _$PersistedCodingKeys: String, CodingKey {
///     case _username = "username"
///     case _password = "password"
/// }
/// ```
///
/// Use `@ModelCodingKey` can mutate the default behavior. To reach this,
/// developer should provide a coding key enumrator with the name **has no underline (`_`)**.
///
/// ```swift
/// @ModelCodingKey
/// enum CustomizeCodingKey: String, CodingKey {
///     case username = "FILUsername"
///     case password = "USRPassword"
/// }
/// ```
///
/// Macro will help you take care of the rest.
///
/// - Important: Always make sure that every property is included in the custom CodingKey.
///
/// Some property should not contains in your customize coding key:
/// - Customize file name (`@StorageName`)
/// - `@PersistedIgnored` properties
///
/// - Warning: Any of the above properties exist in custom coding key may cause unexpected errors.
@attached(peer, names: named(_$PersistedCodingKeys))
public macro ModelCodingKey() = #externalMacro(module: "DocumentDataMacros", type: "ModelCodingKeyMacro")

@attached(peer)
public macro Migration() = #externalMacro(module: "DocumentDataMacros", type: "MigrationMacro")

@attached(member, names: named(init), named(encode))
@attached(extension, conformances: Codable)
public macro _MigrationMiddleware() = #externalMacro(module: "DocumentDataMacros", type: "_MigrationMiddlewareMacro")
