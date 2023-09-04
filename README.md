# Simple Persistence

A small package to easily store objects on disk.

## Features

- Easily convert classes into storable classes
- No code-generation
- Multiple storage strategies for different applications
- No dependencies

## Table of Contents

- [Simple Persistence](#simple-persistence)
  - [Features](#features)
  - [Table of Contents](#table-of-contents)
  - [Setup](#setup)
    - [Create a `Storable` class](#create-a-storable-class)
    - [Register deserializer for your `Storable`](#register-deserializer-for-your-storable)
    - [Create a `Store` for your `Storable`](#create-a-store-for-your-storable)
    - [Putting it together](#putting-it-together)
  - [Usage](#usage)

## Setup

The setup is quite easy and requires three steps:

- Step 1: [Create a `Storable` class](#create-a-storable-class)
- Step 2: [Register deserializer](#register-deserializer-for-your-storable)
- Step 3: [Create a `Store`](#create-a-store-for-your-storable)

[Everything together](#putting-it-together)

### Create a `Storable` class

The first step is to make your class a `Storable`. You will need to implement the `data` getter and a function to create the object from a map (i.e. `fromMap`). In case you implement a copyWith method, make sure that you are copying the `id` field as well (as not make it be modifiable). This is important if you want to be able to update an object.

```dart
class User extends Storable {
    final String name;

    @override
    Map<String, dynamic> get data => {
        'name': name,
    };

    User.fromMap(Map<String, dynamic> map) : name = map['name'];
}
```

Now the `User` class is already done and prepared to be saved and loaded.

### Register deserializer for your `Storable`

The next step is to register your class with a `StorableFactory` so it knows how to deserialize it. You only need one `StorableFactory` instance for your application:

```dart
final sf = StorableFactory();
sf.registerDeserializer(User.fromMap);
```

After this, the `sf.deserialize()` function will be able to automatically figure out which class you want to deserialize if you give it the serialized data and return a `User` object.

### Create a `Store` for your `Storable`

The last step is to create a `Store` that is responsible for the read/write operations. Here you have choose between two different strategies: `JsonFileStore` will store all objects in one single file and `BigJsonStore` will have a separate file for every object (useful if you have a lot of data).

```dart
final userStore = JsonFileStore<User>(
    // This needs to be a path to a JSON file. It can be a [Future] as well. In Flutter it could e. g. be based on `getApplicationDocumentsDirectory()` from the path_provider package.
    path: '/.../.../test.json',
    // This needs to have the deseralizer for the correct type (in this case [User]) registered.
    storableFactory: sf,
);
```

And that's it. You can now use the operations on the store to persist your data.

### Putting it together

All together a simple `user.dart` could look like this:

```dart
final sf = StorableFactory()
    ..registerDeserializer(User.fromMap);

class User extends Storable {
    static final store = JsonFileStore<User>(
        path: '/.../.../user.json',
        storableFactory: sf,
    );

    final String name;

    User(this.name);

    @override
    Map<String, dynamic> get data => {
        'name': name,
    };

    User.fromMap(Map<String, dynamic> map) : name = map['name'];

    User copyWith({String? name}) => 
        User(name ?? this.name)
            ..id = id; // copying the id is IMPORTANT, otherwise a new object will be created in the store.
}
```

## Usage

After the example setup from above you can now easily persist and load data in your app:

```dart
void main() {
    var user = User('John Doe');

    // save user
    user = User.store.save(user); // the id will be set on the returned value

    // get user
    User.store.get(user.id);

    // update user
    final newUser = user.copyWith(name: 'Jane Doe');
    User.store.save(newUser);

    // get a stream of user updates
    // The stream will emit an update everytime the data for that id changes and will be
    // closed when the object is deleted.
    final stream = User.store.listen(user.id);

    // delete user
    User.store.delete(user.id);
}
```
