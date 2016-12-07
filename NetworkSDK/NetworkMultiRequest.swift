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
///    - [(Data?, Error?)], Result for [Request]
public typealias NetworkMultiRequestResultHandler = ([(Data?, Error?)]) ->Void


/// Multi network request progressHandler
///
/// - Parameters:
///    - [NetworkProgressHandler], progress handler for every request
public typealias NetworkMultiRequestProgressHandler = (Progress) ->Void

public class NetworkMultiRequest<T: Mappable> {
  /// Multi Network request queue
  public var networkRequestQueue = NetworkTaskQueue<T>()

  /// Multi Download request
  ///
  /// - Parameters:
  ///   - requestable: [download Request array]
  ///   - handler: Handler, [(Data?, Error?)]
  ///   - progressHandler: [(Progress) ->Void]..., you can set every progress handler.
  public func download(_ requestable: [NetworkRequest<T>], handler: @escaping NetworkMultiRequestResultHandler, _ progressHandler: @escaping NetworkMultiRequestProgressHandler...) {
    networkRequestQueue.download(requestable, handler, progressHandler)
  }
}

public class NetworkTaskQueue<T: Mappable> {

  /// Download group
  public var group: DispatchGroup = DispatchGroup()

  /// Download queue
  public var taskQueue: DispatchQueue = DispatchQueue.global()

  /// Notify queue
  public var notifyQueue: DispatchQueue = DispatchQueue.main

  public func download(_ requests: [NetworkRequest<T>], _ handler: @escaping NetworkMultiRequestResultHandler, _ progressHandler: [NetworkMultiRequestProgressHandler] ) {
    guard requests.count != 0 else {
      handler([])
      return
    }

    var progressInnerhandler = progressHandler
    if progressHandler.count != requests.count {
      let count = requests.count - progressHandler.count
      if count > 0 {
        for _ in 0..<count {
          progressInnerhandler.append({p in })
        }
      }
    }

    var result = [(Data?, Error?)]()
    for (index, requestItem) in requests.enumerated() {
      // Add progress handler
      requestItem.identifier = "\(index)"
      taskQueue.async(group: group) {
        let r = NetworkSyncdownload<T>().download(requestItem, progress: progressInnerhandler[index])
        result.append(r)
      }
    }

    group.notify(queue: notifyQueue) {
      handler(result)
    }
  }
}

/// Sync download
public class NetworkSyncdownload<T: Mappable> {

  /// Semaphore to change async to sync
  public var semaphore = DispatchSemaphore(value: 0)

  /// Current download request
  public var downloadRequest: NetworkRequest<T>?

  public func download(_ request: NetworkRequest<T>, progress: @escaping NetworkProgressHandler) -> (Data?, Error?) {
    var data: Data?
    var error: Error?
    downloadRequest = request

    downloadRequest!.download({ [weak self] (d, e) in
      data = d
      error = e
      self?.semaphore.signal()
      }, progress)

    _ = semaphore.wait(timeout: .distantFuture)

    return (data, error)
  }
}
