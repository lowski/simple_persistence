## 0.3.2

* Add `ValueStream` to the public api (via `package:simple_persistence/utils.dart`)

## 0.3.1

* Fix that only the first listener of a `ValueStream` would get the last value on listening
* Add `listenAll()` on `Store` to get a stream of the list of objects

## 0.3.0

* Remove static functions of `KVStore`
* Change `KVStore` initialization to be like a normal `Store`
* Change `StorableFactory` to a singleton

## 0.2.0

* Add a KV store

## 0.1.1

* Change IDs from custom StorableId to simple String

## 0.1.0

* Initial version.
