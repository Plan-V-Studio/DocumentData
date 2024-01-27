# Create a Persistence Model

Create your first persistence model by using DocumentData.

@Metadata {
    @PageColor(blue)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

## Overview

Persistence model is the basic unit for DocumentData. In common conditions,
DocumentData will create only one store on storage for individual models,
each model only allowed one.

Persistence file will store in `/Container/Application Support`,
it is named same as model's name.

For example, if the model's name is `UserData`, the persistence file named will be `UserData.storage.plist` in default. If you want to change the persistence file name, see ``StorageName()``.

### Create Your Model

To begin using DocumentData, you should create your model first,
the model should be a Swift Class proprerty. 
This is a brief example for storing user's information.

- Tip: Any `Codable` type can be used as a persistent storage type.

```swift
class UserData {
    var username: String
    var password: Data
    var role: UserRole
    var registerDate: Date

    init(
        username: String, 
        password: Data, 
        role: UserRole = .basic, 
        registerDate: Date = Date.now
    ) {
        self.username = username
        self.password = password
        self.role = role
        self.registerDate = registerDate
    }
}
```

In this case, `UserRole` is a `Codable` type. 

**DocumentData can only process `Codable` type, otherwise will caused app crash.**

- Important: You should provide initializer when you create a model.

### Transform Class to Persistence Model

After you create your data model, you need to add ``PersistedModel()`` macro
in front of your class delcaration.

``` swift
@PersistedModel
class UserData {
    // properties...
}
```
Then, this class property should autimatically convert to
persistence model.

### Access and Mutate Persisted Properties

To access persisted properties, it just like access any class
property in swift.

```swift
let userData = UserData()
userData.username
```

To mutate values, it also easy to do.

```swift
let userData = UserData()
userData.username = "John Appleseed"
```
### Customize Which Property Need To Persisted

If you don't wnat persiste a property use ``PersistedIgnored()`` to ignore it.

```swift
@PersistedModel
class UserData {
    @PersistedIgnored
    var requestCount: Int
}
```

In this case, `requestCount` will never persist, all the information storing in this property will lost.

### Continuous Access to Persistent Data

Every model are comform to ``DocumentPersistedModel``, this protocol provide a method which allow us access the persisted data.

```swift
let data = UserData.default
```

``DocumentPersistedModel/default`` can create a model which contain all the datas that persisted. You can access or modify datas.

- Important: Always check whether persisted files are present using the ``DocumentPersistedModel/isPersisted`` method before calling the ``DocumentPersistedModel/default`` method, otherwise the app will stop execution immediately.

## See Also

- ``PersistedModel()``
- ``PersistedIgnored()``
- ``DocumentPersistedModel``
