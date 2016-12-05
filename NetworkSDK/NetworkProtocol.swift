//
//  NetworkProtocol.swift
//  Pods
//
//  Created by Dylan on 2016/11/23.
//
//

import Foundation
import Alamofire


/// Requestable
public protocol Requestable: URLRequestConvertible {

  /// HTTP Request method, default .get, use HTTPMethod type from `Alamofire`
  var method: Methods { get set }

  /// HTTP Request header, default nil, use HTTPHeaders type from `Alamofire`
  var header: [String: String]? { get set }

  /// HTTP Base url, class, struct, enum must implements this method
  var baseURL: String { get set }

  /// HTTP Request path, class, struct, enum must implements this method
  var path: String { get set }

  /// HTTP Request parameters, default nil
  var parameters: [String: Any]? { get set }

  /// HTTP Request option
  var type: NetworkOption { get }

  /// HTTP Request timeout
  ///
  /// - Returns: TimeInterval, default is 15 seconds
  func timeout() -> TimeInterval

  /// HTTP Request Cache policy, will handled by URLProtocol
  ///
  /// - Returns: NetworkCachePolicy, default is none.
  func cachePolicy() -> NetworkCachePolicy

  /// HTTP Request should send when cellular network
  ///
  /// - Returns: Bool value, default is true
  func allowsCellularAccess() -> Bool

  /// HTTP Request should handle cookies
  ///
  /// - Returns: Bool value, default is true
  func httpShouldHandleCookies() -> Bool

  /// Cancel request
  func cancel() -> Swift.Void
}

extension Requestable {

  public func timeout() -> TimeInterval {
    if type == .data {
      return 15
    }
    return 60 * 5
  }

  public func cachePolicy() -> NetworkCachePolicy {
    if type == .data {
      return .none
    }
    return .remoteElseLocal
  }

  public func allowsCellularAccess() -> Bool {
    return true
  }

  public func httpShouldHandleCookies() -> Bool {
    return true
  }

}


/// HTTP Request methods
///
/// - get: GET
/// - post: POST
public enum Methods: String {
  case options = "OPTIONS"
  case get     = "GET"
  case head    = "HEAD"
  case post    = "POST"
  case put     = "PUT"
  case patch   = "PATCH"
  case delete  = "DELETE"
  case trace   = "TRACE"
  case connect = "CONNECT"
}


/// NetworkOption - indicates request type, default is data request
///
/// - data: Normally data request
/// - download: download request
/// - upload: upload request
public enum NetworkOption {
  case data
  case download // Unimplement
  case upload // Unimplement
}


/// HTTP Request cache policy
///
/// - remoteElseLocal: Remote request with failure will try get data from URLCache
/// - none: None
public enum NetworkCachePolicy: String {
  case remoteElseLocal = "rel"
  case none = "n"
}
