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
  private(set) public var sessionManager: Alamofire.SessionManager

  /// default header add to every request
  public var defaultHeader: [String: String] = [:]

  /// base url
  public var baseURL: String = ""

  /// Session delegate
  private(set) public var delegate: Alamofire.SessionDelegate

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

  public func setManager(_ manager: Alamofire.SessionManager) {
    sessionManager = manager
    delegate = sessionManager.delegate
  }

  ///
  private init() {
    var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    defaultHeaders["sdk-version-info"] = "NetworkSDK-0.1.8"

    let configuration = URLSessionConfiguration.default
    configuration.httpCookieAcceptPolicy = .always
    configuration.httpAdditionalHeaders = defaultHeaders

    sessionManager = Alamofire.SessionManager(configuration: configuration)
    delegate = sessionManager.delegate
  }
}


/// Network engin pool global instance
public let Network = NetworkManager.default
