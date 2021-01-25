//
//  ConsoleOutputListener.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 1/25/21.
//

import Foundation

public class ConsoleOutputListener {
  public static let shared: ConsoleOutputListener = ConsoleOutputListener()
  
  /// consumes the messages on STDOUT
  private let inputPipe = Pipe()
  
  /// outputs messages back to STDOUT
  private let outputPipe = Pipe()
  
  /// Buffers strings written to stdout
  public private(set) var contents = ""
  
  private let savedOutputId: Int32
  
  private let queue = DispatchQueue(label: "ConsoleOutputListener.queue")
  
  private init() {
    self.savedOutputId = dup(1)
    // Set up a read handler which fires when data is written to our inputPipe
    inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
      guard let self = self else { return }
      let data = fileHandle.availableData
      if let string = String(data: data, encoding: String.Encoding.utf8), string.isNotEmpty {
        self.contents += string
        self.queue.async {
          self.appendToLogFile(string)
        }
      }
      /// Write input back to stdout
      self.outputPipe.fileHandleForWriting.write(data)
    }
  }
  
  /// Sets up the "tee" of piped output, intercepting stdout then passing it through.
  public func openConsolePipe() {
    let stdoutFileDescriptor: Int32 = 1
    /// Copy STDOUT file descriptor to outputPipe for writing strings back to STDOUT
    dup2(stdoutFileDescriptor, outputPipe.fileHandleForWriting.fileDescriptor)
    /// Intercept STDOUT with inputPipe
    dup2(inputPipe.fileHandleForWriting.fileDescriptor, stdoutFileDescriptor)
  }
  
  /// Tears down the "tee" of piped output.
  public func closeConsolePipe() {
    /// Restore stdout
    fflush(stdout)
    dup2(savedOutputId, 1)
    close(savedOutputId)
    /// Clean pipes
    [inputPipe.fileHandleForReading, outputPipe.fileHandleForWriting].forEach { file in
      file.closeFile()
    }
  }
  
  public func logFileURL() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let fileName = "\(Bundle.main.bundleIdentifier ?? "app").log"
    return paths[0].appendingPathComponent(fileName)
  }
  
  public func getLogFileContents() -> String {
    if let contents = try? String(contentsOf: self.logFileURL(), encoding: .utf8) {
      return contents
    }
    return ""
  }
  
  public func clearLogFile() {
    self.writeToLogFile("")
  }
  
  private func appendToLogFile(_ contents: String) {
    if let fileHandle = try? FileHandle(forWritingTo: logFileURL()),
       let data = contents.data(using: .utf8) {
      defer { fileHandle.closeFile() }
      fileHandle.seekToEndOfFile()
      fileHandle.write(data)
    }
  }
  
  private func writeToLogFile(_ contents: String) {
    do {
      try contents.write(to: logFileURL(), atomically: true, encoding: String.Encoding.utf8)
    } catch let error {
      print(error)
      self.closeConsolePipe()
    }
  }
  
  public func flushLogsToFile() {
    self.appendToLogFile(contents)
  }
}
