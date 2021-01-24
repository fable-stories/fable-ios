//
//  AppBuildSource.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 2/19/20.
//

import Foundation

public enum AppBuildSource: String {
  case simulator
  case testFlight
  case appStore
  
  public static func source() -> AppBuildSource {
    if let path = Bundle.main.appStoreReceiptURL?.path {
      if path.contains("CoreSimulator") {
        return .simulator
      } else if path.contains("sandboxReceipt") {
        return .testFlight
      }
    }
    return .appStore
  }
  
  public static func appVersion() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
  }
  
  public static func appBuild() -> String {
    return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
  }
  
  public static func versionBuild() -> String {
    let version = appVersion(), build = appBuild()
    return "v\(version) (\(build))"
  }
}
