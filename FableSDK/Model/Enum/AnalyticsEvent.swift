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
  case loginDidFail
  
  case didSelectGoogleSignIn
  case didSelectAppleSignIn
  case didSelectEmailsignIn
  
  case appleSignInSucceeded
  case appleSignInFailed
  case googleignInSucceeded
  case googleSignInFailed
  case emailignInSucceeded
  case emailSignInFailed
  
  /// Share
  
  case didCopyShareLink
  
  /// App
  
  case appDidEnterForeground
  case appDidEnterBackground
    
  case didSelectFeedTab
  case didSelectWriterTab
  case didSelectUserProfileTab
  
  /// Feed Screen
  
  case didSelectStoryInFeed
  
  /// Story Detail Screen
  
  case didStartStory
  
  /// Story Screen
  
  case didTapNextMessageInReader
  case didCompleteStoryInReader
  case didDismissReader
  
  /// Creator Landing Screen
  
  case didTapNewDraftStory
  case didTapContinueDraftStory
  case didTapDraftStoryPreview
  case didTapPublishStory
  case didTapUnublishStory
  case didTapDeleteStory
  case didTapDraftStoryDetails
  
  /// Telegram
  
  case didTapTelegramLink
  
  public var rawValue: String {
    switch self {
    case .didCopyShareLink: return "did_copy_share_link"
    case .appDidEnterForeground: return "app_did_enter_foreground"
    case .appDidEnterBackground: return "app_did_enter_background"
    case .didSignUp: return "user_did_signup"
    case .didLogin: return "user_did_login"
    case .didLogout: return "user_did_logout"
    case .loginDidFail: return "login_did_fail"
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
    case .didStartStory: return "did_start_story"
    case .didTapNewDraftStory: return "did_tap_new_draft_story"
    case .didTapContinueDraftStory: return "did_tap_continue_draft_story"
    case .didTapDraftStoryPreview: return "did_tap_draft_story_preview"
    case .didTapDraftStoryDetails: return "did_tap_draft_story_details"
    case .didTapPublishStory: return "did_tap_publish_story"
    case .didTapUnublishStory: return "did_tap_unpublish_story"
    case .didTapDeleteStory: return "did_tap_delete_story"
    case .didTapTelegramLink: return "did_tap_telegram_link"
    }
  }
  
  /// You cannot map an Analytic event ad-hoc
  public init?(rawValue: String) { nil }
}
