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

