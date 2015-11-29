//
//  Appodeal.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 04/07/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AppodealInterstitialDelegate.h"
#import "AppodealBannerDelegate.h"
#import "AppodealVideoDelegate.h"
#import "AppodealRewardedVideoDelegate.h"
#import "AppodealNetworkNames.h"
#import "AppodealUnitSizes.h"
#import "AppodealConstants.h"

#import "AppodealBannerView.h"

#import "AppodealImage.h"
#import "AppodealNativeAdService.h"
#import "AppodealNativeAdViewAttributes.h"
#import "AppodealNativeAdView.h"
#import "UIView+AppodealNativeAd.h"
#import "AppodealNativeAdService.h"

typedef NS_OPTIONS(NSInteger, AppodealAdType) {
    AppodealAdTypeInterstitial      = 1 << 0,
    AppodealAdTypeSkippableVideo    = 1 << 1,
    AppodealAdTypeVideo __attribute__((deprecated("use AppodealAdTypeSkippableVideo"))) = AppodealAdTypeSkippableVideo,
    AppodealAdTypeBanner            = 1 << 2,
    AppodealAdTypeNativeAd          = 1 << 3,
    AppodealAdTypeRewardedVideo     = 1 << 4,
    AppodealAdTypeNonSkippableVideo = AppodealAdTypeRewardedVideo,
    AppodealAdTypeAll               = AppodealAdTypeInterstitial | AppodealAdTypeSkippableVideo | AppodealAdTypeBanner | AppodealAdTypeNativeAd | AppodealAdTypeRewardedVideo
};

typedef NS_ENUM(NSInteger, AppodealShowStyle) {
    AppodealShowStyleInterstitial = 1,
    AppodealShowStyleSkippableVideo,
    AppodealShowStyleVideoOrInterstitial,
    AppodealShowStyleBannerTop,
    AppodealShowStyleBannerCenter,
    AppodealShowStyleBannerBottom,
    AppodealShowStyleRewardedVideo,
    AppodealShowStyleVideo  __attribute__((deprecated("use AppodealShowStyleSkippableVideo"))) = AppodealShowStyleSkippableVideo,
    AppodealShowStyleNonSkippableVideo = AppodealShowStyleRewardedVideo
};

@interface Appodeal : NSObject

+ (instancetype)alloc NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)disableNetworkForAdType:(AppodealAdType)adType name:(NSString *)networkName;
+ (void)disableLocationPermissionCheck;
+ (void)setAutocache:(BOOL)autocache types:(AppodealAdType)types;
+ (BOOL)isAutocacheEnabled:(AppodealAdType)types;

+ (void)initializeWithApiKey:(NSString *)apiKey __attribute__((deprecated));
+ (void)initializeWithApiKey:(NSString *)apiKey types:(AppodealAdType)types;

+ (void)deinitialize;

+ (BOOL)isInitalized;

+ (void)setInterstitialDelegate:(id<AppodealInterstitialDelegate>)interstitialDelegate;
+ (void)setBannerDelegate:(id<AppodealBannerDelegate>)bannerDelegate;
+ (void)setVideoDelegate:(id<AppodealVideoDelegate>)videoDelegate;
+ (void)setRewardedVideoDelegate:(id<AppodealRewardedVideoDelegate>)rewardedVideoDelegate;

+ (UIView *)banner;

+ (BOOL)showAd:(AppodealShowStyle)style rootViewController:(UIViewController *)rootViewController;
+ (void)cacheAd:(AppodealAdType)type;

+ (void)hideBanner;

+ (void)setDebugEnabled:(BOOL)debugEnabled;
+ (NSString *)getVersion;

+ (BOOL)isReadyForShowWithStyle:(AppodealShowStyle)showStyle;

+ (void)confirmUsage:(AppodealAdType)adTypes;

@end

@interface Appodeal (UserMetadata)

+ (void)setUserVkId:(NSString *)vkId;
+ (void)setUserFacebookId:(NSString *)facebookId;
+ (void)setUserEmail:(NSString *)email;
+ (void)setUserBirthday:(NSDate *)birthday;
+ (void)setUserAge:(NSUInteger)age;
+ (void)setUserGender:(AppodealUserGender)gender;
+ (void)setUserOccupation:(AppodealUserOccupation)occupation;
+ (void)setUserRelationship:(AppodealUserRelationship)relationship;
+ (void)setUserSmokingAttitude:(AppodealUserSmokingAttitude)smokingAttitude;
+ (void)setUserAlcoholAttitude:(AppodealUserAlcoholAttitude)alcoholAttitude;
+ (void)setUserInterests:(NSString *)interests;

@end