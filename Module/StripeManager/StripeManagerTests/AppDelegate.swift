//
//  AppDelegate.swift
//  StripeManager
//
//  Created by Andrew Aquino on 3/3/19.
//

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = RootViewController()
    window?.makeKeyAndVisible()
    
    ConfigureStripeManager("pk_test_X2Th1v6ILtFqaEiPK5Ii7Eev")
    
    return true
  }
}
