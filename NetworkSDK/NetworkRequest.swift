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

/// Network response progress
public typealias NetworkProgressHandler = (Progress) ->Swift.Void

/// Network request base class
open class NetworkRequest<T: Mappable>: Requestable {

  /// HTTP Request option - pre type var
  private(set) public var type: NetworkOption = .data

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

  /// HTTP Download to URL, should be file URL
  open var fileURL: URL?

  /// HTTP Download request should resume
  open var resuming: Bool = false

  /// HTTP Upload request data set
  open var uploadedData: [(Data, String, String, String)]?

  /// Identifier for multi request
  open var identifier: String = ""

  /// HTTP Data request
  private(set) public var dataRequest: DataRequest?

  /// HTTP Download request
  private(set) public var downloadRequest: DownloadRequest?

  /// HTTP Upload request
  private(set) public var uploadRequest: UploadRequest?

  /// Network data request result handler
  public typealias NetworkHandler = (T?, Error?) ->Swift.Void

  /// Download request handler
  public typealias NetworkDownloadHandler = (Data?, Error?) ->Swift.Void

  /// Send request to server.
  ///
  /// - Parameters:
  ///   - handler: (T?, Error?) ->Swift.Void
  ///   - progress: (Progress) ->Swift.Void
  /// - Returns: Specific type of `Request` that manages an underlying `URLSessionDataTask`.
  @discardableResult
  open func send(_ handler: @escaping NetworkHandler) ->DataRequest?{
    guard type == .data else {
      // Data request shoud use send method
      return nil
    }

    dataRequest = Network.sessionManager!.request(self)
    if Network.debug == true, let request = dataRequest {
      debugPrint(request)
    }
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
    return dataRequest
  }

  /// Send download request
  ///
  /// - Parameters:
  ///   - handler: download request handler
  ///   - progressHandler: download request progress handler
  /// - Returns: DownloadRequest, manages an underlying `URLSessionDownloadTask`.
  @discardableResult
  open func download(_ handler: @escaping NetworkDownloadHandler, _ progressHandler: @escaping NetworkProgressHandler) ->DownloadRequest? {
    guard type == .download, fileURL?.isFileURL == true, let fURL = fileURL else {
      return nil
    }

    let downloadDestination: DownloadRequest.DownloadFileDestination = { _, _ in
      return (fURL, [.removePreviousFile, .createIntermediateDirectories])
    }

    let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    let cacheURL = cacheFolder.appendingPathComponent("resumingDataCaches/\(fURL.lastPathComponent)")

    // Resum data
    if let resumimgData = try? Data(contentsOf: cacheURL), resuming == true {
      let cData = correctResumeData(resumimgData) ?? resumimgData
      downloadRequest = Network.sessionManager?.download(resumingWith: cData, to: downloadDestination)

      let task = downloadRequest?.task as! URLSessionDownloadTask
      let kResumeCurrentRequest = "NSURLSessionResumeCurrentRequest"
      let kResumeOriginalRequest = "NSURLSessionResumeOriginalRequest"

      if let resumeDic = getResumeDictionary(cData) {
        if task.originalRequest == nil, let originalReqData = resumeDic[kResumeOriginalRequest] as? Data, let originalRequest = NSKeyedUnarchiver.unarchiveObject(with: originalReqData) as? NSURLRequest {
          task.setValue(originalRequest, forKey: "originalRequest")
        }
        if task.currentRequest == nil, let currentReqData = resumeDic[kResumeCurrentRequest] as? Data, let currentRequest = NSKeyedUnarchiver.unarchiveObject(with: currentReqData) as? NSURLRequest {
          task.setValue(currentRequest, forKey: "currentRequest")
        }
      }
    } else {
      downloadRequest = Network.sessionManager?.download(self, to: downloadDestination)
    }

    if Network.debug == true, let request = downloadRequest {
      debugPrint(request)
    }
    downloadRequest?.responseData {
      switch $0.result {
      case .success(let data):
        try? FileManager.default.removeItem(at: cacheURL)
        handler(data, nil)
        break
      case .failure(let error):
        // If resume data && resuming
        if self.resuming == true, let rData = $0.resumeData {
          try? FileManager.default.createDirectory(at: cacheFolder.appendingPathComponent("resumingDataCaches"), withIntermediateDirectories: true, attributes: nil)
          try? rData.write(to: cacheURL)
        }

        handler(nil, error)
        break
      }
    }.downloadProgress(closure: {
      progressHandler($0)
    })

    return downloadRequest
  }

  /// Send upload request
  ///
  /// - Parameters:
  ///   - handler: result handler
  ///   - progressHandler: progress handler
  @discardableResult
  open func upload(_ handler: @escaping NetworkHandler, _ progressHandler: @escaping NetworkProgressHandler) ->Swift.Void {
    guard let data = uploadedData, type == .upload else {
      return
    }

    Network.sessionManager?.upload(multipartFormData: {
      for (fdata, fname, ffilename, ftype) in data {
        $0.append(fdata, withName: fname, fileName: ffilename, mimeType: ftype)
      }
    }, with: self, encodingCompletion: {
      switch $0 {
      case .failure(let error):
        handler(nil, error)
        break
      case .success(let upload, _, _):
        self.uploadRequest = upload
        if Network.debug == true, let request = self.uploadRequest {
          debugPrint(request)
        }
        self.uploadRequest?.responseJSON {
          switch $0.result {
          case .success(let value):
            if let response = $0.response, let request = $0.request, let data = $0.data {
              self.handleResponse(response, request, data)
            }
            handler(Mapper<T>().map(JSONObject: value), nil)
            break
          case .failure(let error):
            handler(nil, error)
            break
          }
        }
        self.uploadRequest?.uploadProgress(closure: {
          progressHandler($0)
        })
        break
      }
    })
  }

  /// Cancel current request
  public func cancel() {
    dataRequest?.cancel()
    downloadRequest?.cancel()
    uploadRequest?.cancel()
  }

  /// Response handler, process cache and cookies
  ///
  /// - Parameters:
  ///   - response: Network response
  ///   - request: Netwoek request
  ///   - data: response data
  private func handleResponse(_ response: HTTPURLResponse, _ request: URLRequest, _ data: Data) {

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
      return URLRequest(url: URL(string: "error://url.is.nil")!)
    }

    var urlRequest = URLRequest(url: baseURL)
    if path.isEmpty == false {
      urlRequest = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
    }

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
  public convenience init(_ path: String, _ method: Methods = .get, _ parameter: [String: Any]? = nil) {
    self.init()
    self.path = path
    self.method = method
    self.parameters = parameter
  }

  /// Initialize a download requestable instance
  ///
  /// - Parameters:
  ///   - path: Sources URL
  ///   - destination: Download to fileURL
  ///   - resume: If request has resuming data, continue download
  public convenience init(_ path: String, destination: URL, _ resume: Bool = false) {
    self.init(path)
    fileURL = destination
    resuming = resume
    type = .download
  }

  /// Initialize a upload requestable instance
  ///
  /// - Parameters:
  ///   - path: path
  ///   - data: an data tupple array
  ///   - parameter: default is nil
  public convenience init(_ path: String, _ data: [(Data, String, String, String)], _ parameter: [String: Any]? = nil) {
    self.init(path, .post, parameter)
    type = .upload
    uploadedData = data
  }

  /// Default initialized
  public init() {
    
  }

}
