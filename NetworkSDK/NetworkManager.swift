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
  public var baseURL: String = "" {
    didSet {
      NetState()
    }
  }

  /// debug opened
  public var debug: Bool = true

  /// Session delegate
  private(set) public var delegate: Alamofire.SessionDelegate?

  /// Net state
  private(set) public var networkState: NetworkReachabilityManager?

  /// Listen Network state
  ///
  /// ```swift
  /// manager?.listener = { status in
  ///     print("Network Status Changed: \(status)")
  /// }
  /// ```
  ///
  /// - Returns: NetworkReachabilityManager instance
  @discardableResult
  private func NetState() {
    if networkState != nil {
      networkState?.stopListening()
      networkState = nil
    }

    networkState = NetworkReachabilityManager(host: baseURL)
    networkState?.startListening()
  }

  /// Use this manager replace the current manager
  ///
  /// - Parameter manager: Alamofire.SessionManager
  public func setManager(_ manager: Alamofire.SessionManager) {
    sessionManager = manager
    delegate = sessionManager?.delegate
  }

  /// Set an secure session manager
  /// 
  /// ```swift
  /// let certificates = ServerTrustPolicy.certificates(in: Bundle.main)
  /// let keys = ServerTrustPolicy.publicKeys(in: Bundle.main)
  /// let tupple = zip(keys, certificates)
  ///
  /// for (key, value) in tupple {
  ///   print("\(key) \(value)")
  /// }
  ///
  /// let sectrustManager = ServerTrustPolicyManager(policies: [Network.baseURL: ServerTrustPolicy.pinCertificates(certificates: certificates, validateCertificateChain: false, validateHost: false)])
  /// ```
  ///
  /// - Parameters:
  ///   - sectrustManager: Responsible for managing the mapping of `ServerTrustPolicy` objects to a given host.
  public func setSecureManager(_ sectrustManager: ServerTrustPolicyManager) {
    commonInit(sectrustManager)
  }

  /// Common Init sessionManager
  ///
  /// - Parameter sectrustManager: Responsible for managing the mapping of `ServerTrustPolicy` objects to a given host.
  private func commonInit(_ sectrustManager: ServerTrustPolicyManager?) {
    let defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders

    let configuration = URLSessionConfiguration.default
    configuration.httpCookieAcceptPolicy = .always
    configuration.httpAdditionalHeaders = defaultHeaders
    configuration.httpCookieStorage = HTTPCookieStorage.shared
    configuration.urlCache = URLCache.shared

    if sessionManager != nil {
      delegate = nil
      sessionManager = nil
    }
    sessionManager = Alamofire.SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: sectrustManager)
    delegate = sessionManager?.delegate
  }

  /// Private init
  private init() {
    commonInit(nil)
  }
}


/// Network engin pool global instance
public let Network = NetworkManager.default
