//
//  RFMAdView.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/6/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

#import "RFMAdDelegate.h"

@class RFMAdRequest;
@interface RFMAdView : UIView

@property (nonatomic, weak, setter = setDelegate:) id<RFMAdDelegate> delegate;
@property (assign, readonly) BOOL shouldPrecache;

#pragma mark -
#pragma mark View Creation
//Use one of the three create functions to create an AdView.
//We recommend to create a view once during the view controller creation
//and then use only the requestFreshAd method to refresh the view with new ads.


/*  If publishers want :
 -- a default (320x50) banner AND
 -- in a default position (top of content view below top navigation bar) AND
 -- do not support rotation
 */

+(RFMAdView *)createAdWithDelegate:(id<RFMAdDelegate>)delegate;



/*  If publishers want:
 -- a custom banner size AND
 -- custom banner location BUT
 -- do not support rotation
 */
+(RFMAdView *)createAdOfFrame:(CGRect)frame
                   withCenter:(CGPoint)center
                 withDelegate:(id<RFMAdDelegate>)delegate;


/*
 If publishers want :
 -- a custom banner size which is same of both landscape and portrait AND
 -- custom banner location AND
 -- support rotation
 */
//SDK will automatically detect rotation and resize

+(RFMAdView *)createAdOfFrame:(CGRect)frame
           withPortraitCenter:(CGPoint)portraitCenter
          withLandscapeCenter:(CGPoint)landscapeCenter
                 withDelegate:(id<RFMAdDelegate>)delegate;

/*  If publishers want :
 -- a full screen interstitial ad
 */
+(RFMAdView *)createInterstitialAdWithDelegate:(id<RFMAdDelegate>)delegate;

#pragma mark -
#pragma mark Ad Request
//Ad API to request an Ad once the AdView has been created.
//You can call this several times during the view lifecycle.
//The returned status shows whether the request was accepted by the SDK.
//For example, if the requestFreshAD function is called when the user
//is viewing the landing page of a previous ad, the SDK does not initiate
//a new ad request and instead returns BOOL “NO” as status.
- (BOOL) requestFreshAdWithRequestParams:(RFMAdRequest *)requestParams;

//This enables pre-caching of ads
- (BOOL) requestCachedAdWithRequestParams:(RFMAdRequest *)requestParams;

// Returns YES when ad can be displayed, NO otherwise
// Applies to cached ads only
- (BOOL) canDisplayCachedAd;

// For cached ad, we must call showCachedAd for display,
// Returns YES when ad can be shown, but if NO
// may also invoke didFailToDisplayAd delegate
-(BOOL) showCachedAd;


// API to adjust  adjust the adview placement for iOS7 and higher if parent view controller
// cannot set the edges for extended layout to none. Call this API for with the correct offset
// values to ensure that the adview is created at the desired coordinates
// Set iOS version to string value of numerical version . ex: @"7.0"
-(void)applyVerticalOffsetForiOSGreaterThan:(NSString *)iosVersion
                             portraitOffset:(CGFloat)portraitOffset
                            landscapeOffset:(CGFloat)landscapeOffset;


//RFMAdSDK sets Audio Category to AVAudioSessionCategoryAmbient during creation.
//Set the audio session category and mode in order to communicate to the system how you intend to use audio in your app.
- (BOOL) setAVAudioSessionCategory:(NSString *)AVAudioSessionCategoryType;

//Get the Version number of RFM SDK in use.
+ (NSString *)rfmSDKVersion;


#pragma mark - Deprecated Methods
/*Replaced with 
 -(void)applyVerticalOffsetForiOSGreaterThan:(NSString *)iosVersion
 portraitOffset:(CGFloat)portraitOffset
 landscapeOffset:(CGFloat)landscapeOffset;
*/
- (void) offsetCentersForiOS7WithPortaitOffset:(CGFloat)portraitOffset
                            andLandscapeOffset:(CGFloat)landscapeOffset DEPRECATED_ATTRIBUTE;

//Replaced with rfmSDKVersion
+ (NSString *)mbsAdVersion DEPRECATED_ATTRIBUTE;

//Replaced with canDisplayCachedAd
- (BOOL) canDisplayAd DEPRECATED_ATTRIBUTE;

//Replace with showCachedAd
- (BOOL) showAd DEPRECATED_ATTRIBUTE;


@end
