//
//  AppDelegate.swift
//  NetworkSDKDemo
//
//  Created by Dylan on 2016/11/28.
//  Copyright © 2016年 dylan. All rights reserved.
//

import UIKit

import ObjectMapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  class RequesterTested: NetworkModel<Any> {
    var imageUri: String?

    override func mapping(map: Map) {
      super.mapping(map: map)
      imageUri <- map["imageUri"]
    }
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    // Base config
    Network.baseURL = "http://ocef2grmj.bkt.clouddn.com"
    let request = NetworkRequest<NetworkModel<Any>>("")


    // http://ocef2grmj.bkt.clouddn.com
    // LLWeChat-master.zip 75.8MB
    // 1083748_3.jpg 51.67kb
    // http://ocef2grmj.bkt.clouddn.com/Group.png

    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentURL.appendingPathComponent("b.jpg")

    let downloadRequest = NetworkRequest<NetworkModel<Any>>("Group.png", destination: fileURL, true)
    downloadRequest.download({

      if $1 == nil { //
        let multipartdata: (Data, String, String, String) = ($0!, "fileData", "a.png", "image/png")
        let uploadRequest = NetworkRequest<NetworkModel<Any>>("uploadResources.json", [multipartdata], ["category": "HEAD"])
        uploadRequest.baseURL = "http://your.domain.com"
        uploadRequest.upload({ (model, error) in
          debugPrint(model ?? "")
        }, {
          debugPrint("upload", $0.fractionCompleted)
        })
      }
    }, {
      debugPrint($0.fractionCompleted)
    })

    return true
  }

}
