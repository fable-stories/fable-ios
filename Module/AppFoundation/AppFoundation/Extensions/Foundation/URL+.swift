//
//  URL+.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 12/26/20.
//

import Foundation

public extension URL {
  var absoluteStringByTrimmingQuery: String {
    let urlcomponents = NSURLComponents(url: self, resolvingAgainstBaseURL: false)
    urlcomponents?.query = nil
    return urlcomponents?.string ?? self.absoluteString
  }
}
