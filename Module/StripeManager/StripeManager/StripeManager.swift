import Foundation
import UIKit
import Stripe

public protocol StripeManagerProtocol {
}

public func ConfigureStripeManager(_ publishableKey: String) {
  STPPaymentConfiguration.shared().publishableKey = publishableKey
}

public final class StripeManager: StripeManagerProtocol {
  private let stpPaymentConfig: STPPaymentConfiguration
  
  public init() {
    stpPaymentConfig = STPPaymentConfiguration.shared()
  }
}
