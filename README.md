# Network

[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)

<p align="center">
  <img src="logo.png" width="350px" height="250px" />
</p>
<p align="center">open source NetworkSDK based on Alamofire</p>

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

code above will send request like: 

```
http://192.168.199.173/call.json
```

###### Download request

```swift
Network.baseURL = "http://ocef2grmj.bkt.clouddn.com"

// http://ocef2grmj.bkt.clouddn.com
// LLWeChat-master.zip 75.8MB
// 1083748_3.jpg 51.67kb

let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let fileURL = documentURL.appendingPathComponent("b.png")

let downloadRequest = NetworkRequest<NetworkModel<Any>>("Group.png", destination: fileURL, true)
downloadRequest.download({

  if $1 == nil { //
    print($0) 
  }
}, {
  debugPrint($0.fractionCompleted)
})
```

###### Upload request

```swift
let multipartdata: (Data, String, String, String) = (data!, "fileData", "a.png", "image/png")
let uploadRequest = NetworkRequest<NetworkModel<Any>>("uploadResources.json", [multipartdata], ["category": "HEAD"])
uploadRequest.baseURL = "http://your.domain.com"

uploadRequest.upload({ 
  debugPrint($0 ?? "")
  debugPrint($1 ?? "")
}, {
  debugPrint("upload", $0.fractionCompleted)
})

```

###### Others

debug log:

```swift
Network.debug = false
```

###### Features

- [x] Simple for use
- [x] Custom request 
- [x] Load from URLCache when remote load failed
- [x] Simple for resuming a download request safer
- [x] Simple upload

###### API docs

[docs](http://www.devdylan.cn/NetworkSDK/0.2.3-beta/api/)

###### Installation

Network is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NetworkSDK", "~> 0.2.3-beta"
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
