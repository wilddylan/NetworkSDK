# Network

###### Example

```swift
import NetworkSDK
import ObjectMapper
```

some configurations:
```swift
Network.defaultHeader = ["a": "b", "c": "d"]
Network.baseURL = "http://192.168.199.173"
```

use objectMapper, create a model:
```swift
struct Options: Mappable {
  var imageUri: String?
  var message: String?
  var dataPath: String?
  var userUri: String?
  var status: String?
  var dataVersion: String?
  var bizUri: String?

  init?(map: Map) {

  }

  mutating func mapping(map: Map) {
    imageUri    <- map["imageUri"]
    message     <- map["message"]
    dataPath    <- map["dataPath"]
    userUri     <- map["userUri"]
    status      <- map["status"]
    dataVersion <- map["dataVersion"]
    bizUri      <- map["bizUri"]
  }
}

```

then, fire:

```swift
let request = NetworkRequest<Options>("call.json")

request.send {
  if let option = $0 {
    print(option.toJSON())
  } else {
    print($1 ?? Error())
}
```

###### Installation

Network is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NetworkSDK"
```

dependency version: 
```ruby
dependency 'ObjectMapper', '~> 2.2.1'
dependency 'Alamofire', '~> 4.1.0'
```

###### Author

Dylan, dylan@china.com

###### License

Network is available under the MIT license. See the LICENSE file for more info.
