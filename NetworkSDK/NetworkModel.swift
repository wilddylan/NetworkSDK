//
//  NetworkResult.swift
//  Pods
//
//  Created by Dylan on 2016/11/24.
//
//

import Foundation
import ObjectMapper

open class NetworkModel<T>: Mappable {

  /// Mapping function in ObjectMapper
  ///
  /// - Parameter map: Map object, (JSON)
  open func mapping(map: Map) {
    code <- map["code"]
    message <- map["message"]
    data <- map["data"]
    datas <- map["datas"]
  }

  public required init?(map: Map) {

  }

  /// Network server response code
  open var code: Int = 0

  /// Network server response message
  open var message: String = ""

  /// Data object
  open var data: T?

  /// Data list object
  open var datas: [T]?

}
