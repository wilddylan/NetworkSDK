//
//  NetworkManager.swift
//  Pods
//
//  Created by Dylan on 2016/11/23.
//
//

import Foundation
import Alamofire

public class NetworkManager {

  /// default network instance
  public static let `default` = NetworkManager()

  /// Session manager
  public var sessionManager: Alamofire.SessionManager

  /// default header add to every request
  public var defaultHeader: [String: String] = [:]

  public var baseURL: String = ""


  /// Listen Network state
  /// - code: 
  /// manager?.listener = { status in
  ///     print("Network Status Changed: \(status)")
  /// }
  /// - Returns: NetworkReachabilityManager instance
  public func NetState() ->NetworkReachabilityManager? {
    let manager = NetworkReachabilityManager(host: baseURL)
    manager?.startListening()
    return manager
  }

  ///
  private init() {
    let configuration = URLSessionConfiguration.default
    configuration.httpCookieAcceptPolicy = .always
    configuration.requestCachePolicy = .returnCacheDataElseLoad

    sessionManager = Alamofire.SessionManager(configuration: configuration)
  }
}


/// Network engin pool global instance
public let Network = NetworkManager.default
