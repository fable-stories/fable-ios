//
//  AppDelegate.swift
//  Fable
//
//  Created by Andrew Aquino on 3/10/19.
//  Copyright © 2019 Andrew Aquino. All rights reserved.
//

import UIKit
import Foundation
import AppFoundation
import FableSDKResolver
import FableSDKViewControllers
import FableSDKModelObjects
import FableSDKModelManagers
import FableSDKResourceManagers
import FableSDKResourceTargets
import FableSDKViewPresenters
import FableSDKModelPresenters
import Firebase
import Firebolt
import GoogleSignIn
import AuthenticationServices
import FirebaseCrashlytics
import os

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
//    let contents = "\(self.logFileContents())\n\(contents)"
//    self.writeToLogFile(contents)
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
//    let contents = "\(self.logFileContents())\n\(self.contents)"
//    self.contents = ""
//    self.writeToLogFile(contents)
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  private let consoleOutputListener = ConsoleOutputListener.shared
  private let resolver = FBSDKResolver()
  
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if isLaunchedFromUnitTest { return true }
    
    consoleOutputListener.openConsolePipe()

    configureFirebaseManager()
    configureNavigationBar()

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .white
    window?.rootViewController = MainTabBarViewController(resolver: resolver)
    window?.makeKeyAndVisible()

    NSSetUncaughtExceptionHandler { exception in
       print(exception)
       print(exception.callStackSymbols)
    }
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    self.consoleOutputListener.flushLogsToFile()
  }
  
  func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    self.consoleOutputListener.flushLogsToFile()
  }
  
  private func configureNavigationBar() {
    let navigationBarAppearance = UINavigationBar.appearance()
    navigationBarAppearance.titleTextAttributes = UINavigationBar.titleAttributes()
    UINavigationBar.setNavigationBarTransparent(nil)
    UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .fableDarkGray
  }
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
  let handled = GIDSignIn.sharedInstance().handle(url)
  return handled
}


private extension AppDelegate {
  var isLaunchedFromUnitTest: Bool {
    ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
  }
}

