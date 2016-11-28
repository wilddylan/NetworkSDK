import PackageDescription

let package = Package(
  name: "NetworkSDK",
  dependencies: [
    .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4.1.0),
    .Package(url: "https://github.com/Hearst-DD/ObjectMapper.git", majorVersion: 2.2.1)
  ]
)
