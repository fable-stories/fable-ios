//
//  String+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 6/30/19.
//

import MobileCoreServices
import Foundation
import UIKit
import CommonCrypto

public extension String {
  var toCamelCase: String {
    var split = self.split(separator: "_")
    if split.count > 0 {
      let first = split.removeFirst()
      return split.reduce("\(first)", { $0 + $1.capitalized })
    }
    return self
  }
  
  var toSnakeCase: String {
    let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
    let normalPattern = "([a-z0-9])([A-Z])"
    return self.processCamalCaseRegex(pattern: acronymPattern)?
      .processCamalCaseRegex(pattern: normalPattern)?.lowercased() ?? self.lowercased()
  }
  
  fileprivate func processCamalCaseRegex(pattern: String) -> String? {
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: count)
    return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
  }
  
  var iso8601Date: Date? {
    return Formatter.iso8601.date(from: self)
  }
  
  func sizeThatFits(_ targetSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), font: UIFont) -> CGSize {
    let label = UILabel()
    label.font = font
    label.text = self
    let size = label.sizeThatFits(targetSize)
    return CGSize(
      width: max(size.width, targetSize.width),
      height: max(size.height, targetSize.height)
    )
  }

  func matches(_ regex: String) -> [String] {
    guard let regex = try? NSRegularExpression(
      pattern: regex,
      options: .caseInsensitive
    ) else { return [] }
    return regex.matches(
      in: self,
      options: [],
      range: NSMakeRange(0, self.count)
    ).map {
      String(self[Range($0.range, in: self)!])
    }
  }
  
  func toIntOrNull() -> Int? { Int(self) }
  

  var mimeTypeForPath: String {
    let url = NSURL(fileURLWithPath: self)
    let pathExtension = url.pathExtension
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
      if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
        return mimetype as String
      }
    }
    return "application/octet-stream"
  }
  
  func toURL() -> URL? { URL(string: self.trimmingCharacters(in: .whitespacesAndNewlines)) }
  
  func index(from: Int) -> Index {
    return self.index(startIndex, offsetBy: from)
  }
  
  func substring(from: Int) -> String {
    let fromIndex = index(from: from)
    return String(self[fromIndex...])
  }
  
  func substring(to: Int) -> String {
    let toIndex = index(from: to)
    return String(self[..<toIndex])
  }
  
  func substring(with r: Range<Int>) -> String {
    let startIndex = index(from: r.lowerBound)
    let endIndex = index(from: r.upperBound)
    return String(self[startIndex..<endIndex])
  }
  
  func hmac(key: String) -> String {
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
    let data = Data(digest)
    return data.map { String(format: "%02hhx", $0) }.joined()
  }
}

public extension Optional where Wrapped == String {
  var isNilOrEmpty: Bool {
    return (self ?? "").isEmpty
  }
}

public func randomUUIDString() -> String { UUID().uuidString }

public extension String {
  func mapTo<T>(_ closure: @escaping (String) -> T) -> T {
    return closure(self)
  }
}
