//
//  NotificationManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 3/20/21.
//

import Foundation
import FirebaseMessaging
import UIKit

public protocol NotificationManager {
  func requestAPN()
}

public final class NotificationManagerImpl: NSObject, NotificationManager {
  
  private let firebaseManager: FirebaseManager

  public init(firebaseManager: FirebaseManager) {
    self.firebaseManager = firebaseManager
    super.init()
    Messaging.messaging().delegate = self
  }
  
  public func requestAPN() {
    let application = UIApplication.shared
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    application.registerForRemoteNotifications()
  }
}

extension NotificationManagerImpl: MessagingDelegate {
  private func messaging(messaging: Messaging, didReceiveRegistrationToken: String) {
    print(didReceiveRegistrationToken)
  }
}

extension NotificationManagerImpl: UNUserNotificationCenterDelegate {
  
}
