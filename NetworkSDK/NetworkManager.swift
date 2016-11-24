//
//  NetworkManager.swift
//  Pods
//
//  Created by Dylan on 2016/11/23.
//
//

import Foundation
import Alamofire


/// Network engin provider
public class NetworkManager {

  /// default network instance
  public static let `default` = NetworkManager()

  /// Session manager
  private(set) public var sessionManager: Alamofire.SessionManager?

  /// default header add to every request
  public var defaultHeader: [String: String] = [:]

  /// base url
  public var baseURL: String = ""

  /// Session delegate
  private(set) public var delegate: Alamofire.SessionDelegate?

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

  /// Use this manager replace the current manager
  ///
  /// - Parameter manager: Alamofire.SessionManager
  public func setManager(_ manager: Alamofire.SessionManager) {
    sessionManager = manager
    delegate = sessionManager?.delegate
  }

  /// Set an secure session manager
  /// Sample code to get certificates:
  /// let certificates = ServerTrustPolicy.certificates(in: Bundle.main)
  /// let keys = ServerTrustPolicy.publicKeys(in: Bundle.main)
  /// let tupple = zip(keys, certificates)

  /// for (key, value) in tupple {
  ///   print("\(key) \(value)")
  /// }
  ///
  /// let sectrustManager = ServerTrustPolicyManager(policies: [Network.baseURL: ServerTrustPolicy.pinCertificates(certificates: certificates, validateCertificateChain: false, validateHost: false)])
  /// - Parameters:
  ///   - sectrustManager: Responsible for managing the mapping of `ServerTrustPolicy` objects to a given host.
  public func setSecureManager(_ sectrustManager: ServerTrustPolicyManager) {
    commonInit(sectrustManager)
  }

  /// Common Init sessionManager
  ///
  /// - Parameter sectrustManager: Responsible for managing the mapping of `ServerTrustPolicy` objects to a given host.
  private func commonInit(_ sectrustManager: ServerTrustPolicyManager?) {
    var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    defaultHeaders["sdk-version-info"] = "NetworkSDK-0.1.8"

    let configuration = URLSessionConfiguration.default
    configuration.httpCookieAcceptPolicy = .always
    configuration.httpAdditionalHeaders = defaultHeaders
 
    sessionManager = Alamofire.SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: sectrustManager)
    delegate = sessionManager?.delegate
  }

  ///
  private init() {
    commonInit(nil)
  }
}


/// Network engin pool global instance
public let Network = NetworkManager.default
