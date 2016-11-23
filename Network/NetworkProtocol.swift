//
//  NetworkProtocol.swift
//  Pods
//
//  Created by Dylan on 2016/11/23.
//
//

import Foundation
import Alamofire

public protocol Requestable: URLRequestConvertible {

  /// HTTP Request method, default .get, use HTTPMethod type from `Alamofire`
  ///
  /// - Returns: enum HTTPMethod
  var method: Methods { get set }


  /// HTTP Request header, default nil, use HTTPHeaders type from `Alamofire`
  ///
  /// - Returns: [String: String]
  var header: [String: String]? { get set }


  /// HTTP Base url, class, struct, enum must implements this method
  ///
  /// - Returns: String like `http://example.com`
  var baseURL: String { get set }


  /// HTTP Request path, class, struct, enum must implements this method
  ///
  /// - Returns: String like `/path`, `/usr/create`
  var path: String { get set }


  /// HTTP Request parameters, default nil
  ///
  /// - Returns: A dictionary of parameters to apply to a `URLRequest`.
  var parameters: [String: Any]? { get set }

}


/// HTTP Request methods
///
/// - get: GET
/// - post: POST
public enum Methods: String {
  case get = "GET"
  case post = "POST"
}
