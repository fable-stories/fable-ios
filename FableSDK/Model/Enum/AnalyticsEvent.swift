//
//  AnalyticEvent.swift
//  FableSDKEnums
//
//  Created by Andrew Aquino on 12/20/20.
//

import Foundation

/*
 - Screens
 - [ ]  Track Tab Selection
 - Story consumption
 - [ ]  Track User opens Story
 - [ ]  Track User dismisses Story
 - [ ]  Track User completes Story (reached end of Story)
 - [ ]  Start time open Story → Stop time complete Story
 - [ ]  Track User Tap
 - [ ]  Start time from last Tap → current Tap
 - Sign Ups
 - [ ]  Track which Sign In method was used
 - [ ]  Track Sign In method Success/Failure
 - Story Creation
 - [ ]  Track Story Creation Count
 - [ ]  Track Character List Tap
 - [ ]  Track Character Creation Button Tap
 - [ ]  Track Character Alignment Tap
 - [ ]  Track Alignment Selection
 - [ ]  Track Character Color Tap
 - [ ]  Track Color Selection
 - [ ]  Track Message Creation Count
 - [ ]  Track Message Update Count
 - [ ]  Track Message Deletion Count
 - [ ]  Track Story Detail Fields Updates
 - [ ]  Track Story Publish Result
 - [ ]  Track Story Deletion Count
 */
public protocol AnalyticsEventIdentifiable {
  var rawValue: String { get }
}

public enum AnalyticsEvent: RawRepresentable, AnalyticsEventIdentifiable {
  /// Sign In Screen
  
  case didSignUp
  case didLogin
  case didLogout
  
  case didSelectGoogleSignIn
  case didSelectAppleSignIn
  case didSelectEmailsignIn
  
  case appleSignInSucceeded
  case appleSignInFailed
  case googleignInSucceeded
  case googleSignInFailed
  case emailignInSucceeded
  case emailSignInFailed
  
  case didSelectFeedTab
  case didSelectWriterTab
  case didSelectUserProfileTab
  
  /// Feed Screen
  
  case didSelectStoryInFeed
  
  /// Story Screen
  
  case didTapNextMessageInReader
  case didCompleteStoryInReader
  case didDismissReader
  
  public var rawValue: String {
    switch self {
    case .didSignUp: return "user_did_signup"
    case .didLogin: return "user_did_login"
    case .didLogout: return "user_did_logout"
    case .didSelectGoogleSignIn: return "selected_google_sign_in"
    case .didSelectAppleSignIn: return "selected_apple_sign_in"
    case .didSelectEmailsignIn: return "selected_email_sign_in"
    case .appleSignInSucceeded: return "apple_sign_in_succeeded"
    case .appleSignInFailed: return "apple_sign_in_failed"
    case .googleignInSucceeded: return "google_sign_in_succeeded"
    case .googleSignInFailed: return "google_sign_in_failed"
    case .emailignInSucceeded: return "email_sign_in_succeeded"
    case .emailSignInFailed: return "email_sign_in_failed"
    case .didSelectFeedTab: return "selected_feed_tab"
    case .didSelectWriterTab: return "selected_writer_tab"
    case .didSelectUserProfileTab: return "selected_user_profile_tab"
    case .didSelectStoryInFeed: return "selected_story_in_feed"
    case .didTapNextMessageInReader: return "tapped_next_message_in_reader"
    case .didCompleteStoryInReader: return "completed_story_in_reader"
    case .didDismissReader: return "dismissed_reader"
    }
  }
  
  /// You cannot map an Analytic event ad-hoc
  public init?(rawValue: String) { nil }
}
