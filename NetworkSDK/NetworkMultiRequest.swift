//
//  NetworkMultiRequest.swift
//  NetworkSDKDemo
//
//  Created by Dylan on 2016/12/7.
//  Copyright © 2016年 dylan. All rights reserved.
//

import Foundation
import ObjectMapper

/// Multi network request result handler
///
/// - Parameters:
///    - [T], Result for [Request]
///    - [Error], Error for [Request]
///    - Bool, All request is succeed?
public typealias NetworkMultiRequestResultHandler = ([String: (Mappable?, Error?)], Bool) ->Void


/// Multi network request progressHandler
///
/// - Parameters:
///    - [Progress], progress for every request
///    - Int, what's index completed
public typealias NetworkMultiRequestProgressHandler = ([Progress?], Int) ->Void

public class NetworkMultiRequest {

  static func send(_ requestable: [NetworkRequest<NetworkModel<Any>>], handler: @escaping NetworkMultiRequestResultHandler) {
    let networkRequestQueue = NetworkTaskQueue()
    networkRequestQueue.sendRequest(requestable, handler);
  }
}

public class NetworkTaskQueue {

  public var group: DispatchGroup = DispatchGroup()
  public var taskQueue: DispatchQueue = DispatchQueue.global()
  public var notifyQueue: DispatchQueue = DispatchQueue.main

  public func sendRequest(_ request: [NetworkRequest<NetworkModel<Any>>], _ handler: @escaping NetworkMultiRequestResultHandler) {
    guard request.count != 0 else {
      handler([: ], false)
      return
    }

    group.notify(queue: notifyQueue) {
    }
  }
}
