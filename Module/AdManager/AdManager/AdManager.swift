//
//  AdManager.swift
//  AdManagerTest
//
//  Created by Bijan Fazeli on 4/2/19.
//

import GoogleMobileAds
import Result
import FBSDKLoginKit

public final class AdManager: NSObject {
  // MARK: Constants
  public static let testAdId = "ca-app-pub-3940256099942544/4411468910"
  
  /// MARK: Enums

  public enum ProviderConfiguration {
    case google(adId: String)
  }
  
  public enum AdSuccess {
    case didDismiss
  }

  public enum AdError: Error {
    case noAdsLoaded
    case adFailedToLoad
    case adInterrupted
  }

  // MARK: - Properties
  
  private let providers: [ProviderConfiguration]
  
  /// Google Ads
  private var googleInterstitial: GADInterstitial?
  
  /// Callback Handlers
  fileprivate var onComplete: ((Result<AdSuccess, AdError>) -> Void)?

  // MARK: - LifeCycle
  public init(withProviders providers: ProviderConfiguration...) {
    self.providers = providers
    super.init()
    createAndLoadAds()
  }
  
  // MARK: - Methods
  
  public class func configure() {
    // ???
  }
  
  /// loads ads for each provider
  private func createAndLoadAds() {
    providers.forEach(createAndLoadAd)
  }
  
  /// loads an ad for a provider
  private func createAndLoadAd(for provider: ProviderConfiguration) {
    switch provider {
    case let .google(adId):
      guard self.googleInterstitial == nil else { return }
      // Creating a google interstitial and preloading it
      let interstitial = GADInterstitial(adUnitID: adId)
      let request = GADRequest()
      request.testDevices = [kGADSimulatorID]
      interstitial.delegate = self
      interstitial.load(request)
      self.googleInterstitial = interstitial
    }
  }

  public func showAd(in viewController: UIViewController, onComplete: @escaping ((Result<AdSuccess, AdError>) -> Void)) {
    guard let googleInterstitial = googleInterstitial, googleInterstitial.isReady else {
      onComplete(.failure(.adFailedToLoad))
      return
    }
    self.onComplete = onComplete
    /// blocks the caller's flow
    googleInterstitial.present(fromRootViewController: viewController)
  }
}

// MARK: - Google Interstitial lifecycle methods
extension AdManager: GADInterstitialDelegate {
  public func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
    self.onComplete?(.failure(.adFailedToLoad))
  }
  
  public func interstitialDidDismissScreen(_ ad: GADInterstitial) {
    self.googleInterstitial = nil
    createAndLoadAds()
    self.onComplete?(.success(.didDismiss))
  }
}
