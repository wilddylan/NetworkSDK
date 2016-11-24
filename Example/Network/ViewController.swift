//
//  ViewController.swift
//  Network
//
//  Created by Dylan on 11/23/2016.
//  Copyright (c) 2016 Dylan. All rights reserved.
//

import UIKit
import NetworkSDK
import ObjectMapper

struct User: Mappable {
  var name: String?

  mutating func mapping(map: Map) {
    name <- map["name"]
  }

  init?(map: Map) {

  }
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    Network.defaultHeader = ["token": "MTMwODg0ODgyODgxMjM0NTk4NzY1YQ=="]
    Network.baseURL = "http://localhost:3000"

    NetworkRequest<User>("user.json").send { object, error in
      print(object?.name ?? "")
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

