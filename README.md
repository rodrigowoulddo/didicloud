# didicloud

[![Version](https://img.shields.io/cocoapods/v/didicloud.svg?style=flat)](https://cocoapods.org/pods/didicloud)
[![License](https://img.shields.io/cocoapods/l/didicloud.svg)](https://cocoapods.org/pods/didicloud)
[![Platform](https://img.shields.io/cocoapods/p/didicloud.svg?style=flat)](https://cocoapods.org/pods/didicloud)

didcloud makes CloudKit operations easier and less verbose.

## Examples

### Models
The classes you will persist as resources on CloudKit must conform with the `Storable` protocol, as the example shows:
```swift
import Foundation
import CloudKit
import didicloud

class Todo: Storable {
    
    /// CloudKit resource name
    public class override var reference: String { return "Todo" }
    
    /// Custom atributes
    var name: String
    var description: String?
    
    /// Storable init
    required init(_ record: CKRecord) {

        self.name = record["name"] as! String
        self.description = record["description"] as? String
        super.init(record)
    }
    
    /// Custom init
    init(name: String, description: String?) {
        self.name = name
        self.description = description
        super.init()
    }
}
```
### CRUD Operations
And a **request** for the list of objects can be done this way:
```swift
        Storage.getAll() {
            (result: Result<[Todo], Error>) in
            
            switch result {
                
            case.failure(let error):
                /// Deal with error
                print(error.localizedDescription)
                
            case .success(let todos):
                /// Use the returned items
            }
        }
```

The **creation** of a new resource can be done this way:
```swift
        let newTodo = Todo(name: name, description: description)
        
        Storage.create(newTodo) {
            result in  
            switch result {
                
            case .failure(let error): 
                /// Deal with error
                print(error)

            case .success(let todo):
                /// Continue...
            }
        }
```

The **update** of a resource can be done this way:
```swift
        todo.name = "New name"
        todo.description = "New description"

        Storage.update(todo) {
            result in
            
            switch result {
                
            case .failure(let error): 
                /// Deal with error
                print(error)

            case .success(let todo):
                /// Continue...
            }
        }
```

The **deletion** of a resource can be done this way:
```swift
        Storage.remove(id) {
            result in
            
            switch result {
                
            case.failure(let error):
                /// Deal with error
                print(error)
                
            case .success(let deletedID):
                /// Continue...
            }
        }
```

### Public and Private Databases

You can specify if the operation occurs in the private or public CloudKit database. It can be done this way:

```swift
    Storage.getAll(storageType: .publicStorage) { 
        // ... 
    }
```

All CRUD methods accept the `storageType` option and the default value is `.privateStorage`.

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
In order to make CloudKit requests you must have an active apple developer enrolment. Also, you need to register your app identifier with CloudKit capabilities and create your object mirrors at CloudKit Dashboard. You can use [this tutorial](https://www.raywenderlich.com/4878052-cloudkit-tutorial-getting-started) to register the identifier and create CloudKit resources.

## Installation

didicloud is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'didicloud'
```

## Author

[Rodrigo Giglio](https://github.com/rodrigowoulddo)

## License

didicloud is available under the MIT license. See the LICENSE file for more info.
