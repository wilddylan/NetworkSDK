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
  open var parameters: [String : Any]? = nil

  /// HTTP Request path, class, struct, enum must implements this method
  open var path: String = ""

  /// HTTP Base url, class, struct, enum must implements this method
  open var baseURL: String = Network.baseURL

  /// HTTP Request header, default nil, use HTTPHeaders type from `Alamofire`
  open var header: [String : String]? = nil

  /// HTTP Request method, default .get, use HTTPMethod type from `Alamofire`
  open var method: Methods = .get

  private(set) public var dataRequest: DataRequest?

  /// Network result handler
  ///
  /// - Parameters:
  ///   - T: Mappable type
  ///   - Error: Response error
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
    dataRequest = Network.sessionManager!.request(self)
    dataRequest!.responseJSON {
      switch $0.result {
      case .success(let value):
        if let response = $0.response, let request = $0.request, let data = $0.data {
          self.handleResponse(response, request, data)
        }
        handler(Mapper<T>().map(JSONObject: value), nil)
        break
      case .failure(let error):
        // If with cachepolicy
        if self.cachePolicy() == .remoteElseLocal {
          if let cResponse = URLCache.shared.cachedResponse(for: $0.request!) {
            if let jsonObject = try? JSONSerialization.jsonObject(with: cResponse.data, options: JSONSerialization.ReadingOptions.mutableContainers) {
              handler(Mapper<T>().map(JSONObject: jsonObject), nil)
              break
            }
          }
        }
        handler(nil, error)
        break
      }
    }
    return dataRequest!
  }

  public func cancel() {
    dataRequest?.cancel()
  }

  func handleResponse(_ response: HTTPURLResponse, _ request: URLRequest, _ data: Data) {

    // cache policy
    if cachePolicy() == .remoteElseLocal {
      let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: .allowed)
      URLCache.shared.storeCachedResponse(cachedResponse, for: request)
    }

    // handle cookie
    if httpShouldHandleCookies() == true {
      let cookie = HTTPCookie.cookies(withResponseHeaderFields: response.allHeaderFields as! [String: String], for: response.url!)
      HTTPCookieStorage.shared.setCookies(cookie, for: response.url!, mainDocumentURL: request.mainDocumentURL)
    }
  }

  /// Return URLRequest
  ///
  /// - Returns: URLRequest
  /// - Throws: When caught error
  open func asURLRequest() throws -> URLRequest {
    guard let baseURL = try? baseURL.asURL() else {
      return URLRequest(url: URL(string: "error://url is nil")!)
    }

    var urlRequest = URLRequest(url: URL(string: path, relativeTo: baseURL)!)

    urlRequest.httpMethod = method.rawValue
    urlRequest.timeoutInterval = timeout()
    urlRequest.allowsCellularAccess = allowsCellularAccess()
    urlRequest.httpShouldHandleCookies = httpShouldHandleCookies()

    header?.forEach {
      urlRequest.addValue($1, forHTTPHeaderField: $0)
    }

    Network.defaultHeader.forEach {
      urlRequest.addValue($1, forHTTPHeaderField: $0)
    }

    return try URLEncoding.default.encode(urlRequest, with: parameters)
  }


  /// Initialize a requestable instance
  ///
  /// - Parameters:
  ///   - path: API path, will relativeTo to baseURL
  ///   - method: defult is .get
  ///   - parameter: default is nil
  public init(_ path: String, _ method: Methods = .get, _ parameter: [String: Any]? = nil) {
    self.path = path
    self.method = method
    self.parameters = parameter
  }

  private init() {

  }

}
