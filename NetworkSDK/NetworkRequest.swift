//
//  NetworkRequest.swift
//  Pods
//
//  Created by Dylan on 2016/11/23.
//
//

import Foundation
import Alamofire
import ObjectMapper


/// Network request base class
open class NetworkRequest<T: Mappable>: Requestable {

  /// HTTP Request option - pre type var
  public var type: NetworkOption = .data

  /// HTTP Request parameters, default nil
  ///
  /// - Returns: A dictionary of parameters to apply to a `URLRequest`.
  open var parameters: [String : Any]? = nil

  /// HTTP Request path, class, struct, enum must implements this method
  ///
  /// - Returns: String like `/path`, `/usr/create`
  open var path: String = ""

  /// HTTP Base url, class, struct, enum must implements this method
  ///
  /// - Returns: String like `http://example.com`
  open var baseURL: String = Network.baseURL

  /// HTTP Request header, default nil, use HTTPHeaders type from `Alamofire`
  ///
  /// - Returns: [String: String]
  open var header: [String : String]? = nil

  /// HTTP Request method, default .get, use HTTPMethod type from `Alamofire`
  ///
  /// - Returns: enum HTTPMethod
  open var method: Methods = .get

  /// Network result handler
  public typealias NetworkHandler = (T?, Error?) ->Swift.Void

  /// Network response progress
  public typealias NetworkDownloadProgress = (Progress) ->Swift.Void

  /// Send request to server.
  ///
  /// - Parameters:
  ///   - handler: (T?, Error?) ->Swift.Void
  ///   - progress: (Progress) ->Swift.Void
  /// - Returns: Specific type of `Request` that manages an underlying `URLSessionDataTask`.
  @discardableResult
  open func send(_ handler: @escaping NetworkHandler) ->DataRequest{
    return Network.sessionManager!.request(self).responseJSON {
      switch $0.result {
      case .success(let value):
        handler(Mapper<T>().map(JSONObject: value), nil)
        break
      case .failure(let error):
        handler(nil, error)
        break
      }
    }
  }


  /// Return URLRequest
  ///
  /// - Returns: URLRequest
  /// - Throws: When caught error
  open func asURLRequest() throws -> URLRequest {
    guard let baseURL = try? self.baseURL.asURL() else {
      return URLRequest(url: URL(string: "error://url is nil")!)
    }

    var urlRequest = URLRequest(url: URL(string: self.path, relativeTo: baseURL)!)
    urlRequest.httpMethod = self.method.rawValue

    self.header?.forEach {
      urlRequest.addValue($1, forHTTPHeaderField: $0)
    }

    Network.defaultHeader.forEach {
      urlRequest.addValue($1, forHTTPHeaderField: $0)
    }

    return try URLEncoding.default.encode(urlRequest, with: self.parameters)
  }


  /// Initialize a requestable instance
  ///
  /// - Parameters:
  ///   - path: API path, will relativeTo to baseURL
  ///   - method: defult is .get
  ///   - parameter: default is nil
  public init(_ path: String, _ method: Methods = .get, _ parameter: [String: Any]? = nil) {
    self.path = path
    self.parameters = parameter
    self.method = method
  }

}
