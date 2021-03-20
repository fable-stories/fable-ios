//
//  Exception.swift
//  AppFoundation
//
//  Created by MacBook Pro on 8/7/20.
//

import Foundation

public struct Exception: LocalizedError, Equatable {
  public let errorDescription: String
  public init(_ errorDescription: String = "", file: String = #file, function: String = #function, line: Int = #line) {
    // let trace = "\(file)_\(function)_\(line)"
    self.errorDescription = "\(errorDescription)"
  }
  public init(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
    let errorMessage = (error as NSError).debugDescription
    self.init(errorMessage, file: file, function: function, line: line)
  }
}
