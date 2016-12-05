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
    Network.debug = false
//    NetworkRequest<RequesterTested>("").send {
//      print($0?.toJSON() ?? "", $1 ?? "")
//    }

    // http://ocef2grmj.bkt.clouddn.com
    // LLWeChat-master.zip 75.8MB
    // 1083748_3.jpg 51.67kb
    // http://ocef2grmj.bkt.clouddn.com/Group.png

    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentURL.appendingPathComponent("b.jpg")

    let downloadRequest = NetworkRequest<NetworkModel<Any>>("Group.png", destination: fileURL, true)
    downloadRequest.download({

      if $1 == nil { //
        print($0)
//        let multipartdata: (Data, String, String, String) = (data!, "fileData", "a.png", "image/png")
//        let uploadRequest = NetworkRequest<NetworkModel<Any>>("uploadResources.json", [multipartdata], ["category": "HEAD"])
//        uploadRequest.baseURL = "http://user.zhaogeshi.com"
//        uploadRequest.upload({ (model, error) in
//          debugPrint(model ?? "")
//        }, {
//          debugPrint("upload", $0.fractionCompleted)
//        })
      }
    }, {
      debugPrint($0.fractionCompleted)
    })

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

