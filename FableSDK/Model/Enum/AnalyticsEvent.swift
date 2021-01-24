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

public enum AnalyticsEvent: String, RawRepresentable, AnalyticsEventIdentifiable {

  /// Sign In Screen
  
  case didSelectGoogleSignIn = "selected_google_sign_in"
  case didSelectAppleSignIn = "selected_apple_sign_in"
  case didSelectEmailsignIn = "selected_email_sign_in"
  
  case appleSignInSucceeded = "apple_sign_in_succeeded"
  case appleSignInFailed = "apple_sign_in_failed"
  case googleignInSucceeded = "google_sign_in_succeeded"
  case googleSignInFailed = "google_sign_in_failed"
  case emailignInSucceeded = "email_sign_in_succeeded"
  case emailSignInFailed = "email_sign_in_failed"
  
  case didSelectFeedTab = "selected_feed_tab"
  case didSelectWriterTab = "selected_writer_tab"
  case didSelectUserProfileTab = "selected_user_profile_tab"
  
  // Feed Screen
  
  case didSelectStoryInFeed = "selected_story_in_feed"
  
  /// Reader Screen
  
  case didTapNextMessageInReader = "tapped_next_message_in_reader"
  case didCompleteStoryInReader = "completed_story_in_reader"
  case didDismissReader = "dismissed_reader"
}
