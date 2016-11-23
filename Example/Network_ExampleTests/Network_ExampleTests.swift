//
//  Network_ExampleTests.swift
//  Network_ExampleTests
//
//  Created by Dylan on 2016/11/23.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import XCTest
import NetworkSDK
import ObjectMapper

class Network_ExampleTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    Network.defaultHeader = ["a": "b", "c": "d"]
    Network.baseURL = "http://192.168.199.173"
  }

  override func tearDown() {
    Network.defaultHeader = [:]
    super.tearDown()
  }

  func testDefaultHeaderSetting() {
    XCTAssertEqual("b", Network.defaultHeader["a"])
    XCTAssertEqual("d", Network.defaultHeader["c"])
  }

  func testBasicNetworkRequest() {
    let request = NetworkRequest<Options>("")

    XCTAssertEqual("", request.path)
    XCTAssertNil(request.parameters)
    XCTAssertNil(request.header)
  }

  func testRequest() {
    let request = NetworkRequest<Options>("call.json")

    XCTAssertTrue(request.method == .get)
    XCTAssertEqual("http://192.168.199.173", request.baseURL)
    XCTAssertEqual("call.json", request.path)

    let expectation = self.expectation(description: "request wait")

    request.send {
      if let option = $0 {
        print(option.toJSON())
        XCTAssertEqual("http://static.zhaogeshi.com", option.imageUri)
        XCTAssertEqual("successful", option.status)
      } else {
        print($1 ?? "error")
      }

      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}

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
