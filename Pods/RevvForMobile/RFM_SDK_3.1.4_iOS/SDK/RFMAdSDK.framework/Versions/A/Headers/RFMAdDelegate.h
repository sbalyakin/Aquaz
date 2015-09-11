//
//  RFMAdDelegate.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/27/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

@import Foundation;
@import UIKit;

@class RFMAdView;
@protocol RFMAdDelegate <NSObject>

@required
#pragma mark -
#pragma mark Required Methods

@optional
#pragma mark -
#pragma mark Optional Notification Methods

//SuperView of RFMAdView
//Set this delegate method for optimum user experience with rich media ads
//that need to modify the view to non-standard sizes during user interaction
-(UIView *)rfmAdSuperView;

//The View controller which originated ad request.
//For best results, please return the view controller whose content view covers full
//screen(apart from tabbar,nav bar and status bar. If the view controller which
//requested for ads does not have full screen access then return the parent view controller
//which has full screen access.
-(UIViewController *)viewControllerForRFMModalView;

// Sent when an ad request has been made to the Server. Useful for checking the
// request URL.
- (void)didRequestAd:(RFMAdView *)adView withUrl:(NSString *)requestUrlString;

// Sent when an ad request loaded an ad; this is a good opportunity to add
// this view to the hierachy, if it has not yet been added.
- (void)didReceiveAd:(RFMAdView *)adView;

// Sent when an ad request failed to load an ad.This is a good opportunity to
// remove the adview from superview if it has been added
- (void)didFailToReceiveAd:(RFMAdView *)adView reason:(NSString *)errorReason;

// sent when ad is displayed
- (void)didDisplayAd:(RFMAdView *)adView;

// sent when ad fails to display
- (void)didFailToDisplayAd:(RFMAdView *)adView reason:(NSString *)errorReason;

// Sent just before presenting a full ad landing view, in response to clicking
// on an ad. Use this opportunity to stop animations, time sensitive interactions, etc.
- (void)willPresentFullScreenModalFromAd:(RFMAdView *)adView;

// Sent just after presenting a full ad landing view, in response to clicking
// on an ad
- (void)didPresentFullScreenModalFromAd:(RFMAdView *)adView;

// Sent just before dismissing the full ad landing view, in response to clicking
// of close/done button on the landing view
- (void)willDismissFullScreenModalFromAd:(RFMAdView *)adView;

// Sent just after dismissing a full screen view. Use this opportunity to
// restart anything you may have stopped as part of -willPresentFullScreenModalFromAd:.
- (void)didDismissFullScreenModalFromAd:(RFMAdView *)adView;

// Sent if the application will enter background (user touched home button, or clicked
// a button which triggered another application and sent the current application in
// background) while the ad banner was still loading.
// Prior to calling this function, RFMAdView will stop loading the banner
//
// Recommendation for publishers: We recommend that you handle this delegate callback
// and remove the RFMAdView instance from superview when you receive this callback.
- (void)adViewDidStopLoadingAndEnteredBackground:(RFMAdView *)adView;

// Sent just before dismissing the interstitial view, in response to clicking
// of close/done button on the interstitial ad
-(void)willDismissInterstitialFromAd:(RFMAdView *)adView;

// Sent just after dismissing the interstitial view, in response to clicking
// of close/done button on the interstitial ad
-(void)didDismissInterstitial;


#pragma mark - DEPRECATED METHODS

//The View controller which originated ad request.
//For best results, please return the view controller whose content view covers full
//screen(apart from tabbar,nav bar and status bar. If the view controller which
//requested for ads does not have full screen access then return the parent view controller
//which has full screen access.

-(UIViewController *)currentViewControllerForRFMAd:(RFMAdView *)rfmAdView DEPRECATED_ATTRIBUTE;


- (void)didFailToReceiveAd:(RFMAdView *)adView DEPRECATED_ATTRIBUTE;


// sent when ad fails to display
- (void)didFailToDisplayAd:(RFMAdView *)adView DEPRECATED_ATTRIBUTE;

@end
