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
#import "AppodealNetworkNames.h"
#import "AppodealUnitSizes.h"
#import "AppodealConstants.h"


typedef NS_OPTIONS(NSInteger, AppodealAdType) {
    AppodealAdTypeInterstitial = 1 << 0,
    AppodealAdTypeVideo        = 1 << 1,
    AppodealAdTypeBanner       = 1 << 2,
    AppodealAdTypeAll          = AppodealAdTypeInterstitial | AppodealAdTypeVideo | AppodealAdTypeBanner
};

typedef NS_ENUM(NSInteger, AppodealShowStyle) {
    AppodealShowStyleInterstitial = 1,
    AppodealShowStyleVideo,
    AppodealShowStyleVideoOrInterstitial,
    AppodealShowStyleBannerTop,
    AppodealShowStyleBannerCenter,
    AppodealShowStyleBannerBottom
};

@interface Appodeal : NSObject

+ (instancetype)alloc NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)disableNetworkForAdType:(AppodealAdType)adType name:(NSString *)networkName;
+ (void)disableLocationPermissionCheck;
+ (void)setAutocache:(BOOL)autocache types:(AppodealAdType)types;
+ (BOOL)isAutocacheEnabled:(AppodealAdType)types;

+ (void)initializeWithApiKey:(NSString *)apiKey; // All ad types with autocache
+ (void)initializeWithApiKey:(NSString *)apiKey types:(AppodealAdType)types;

+ (void)deinitialize;

+ (BOOL)isInitalized;

+ (void)setInterstitialDelegate:(id<AppodealInterstitialDelegate>)interstitialDelegate;
+ (void)setBannerDelegate:(id<AppodealBannerDelegate>)bannerDelegate;
+ (void)setVideoDelegate:(id<AppodealVideoDelegate>)videoDelegate;

+ (UIView *)banner;

+ (BOOL)showAd:(AppodealShowStyle)style rootViewController:(UIViewController *)rootViewController;
+ (void)cacheAd:(AppodealAdType)type;

+ (void)hideBanner;

+ (void)setDebugEnabled:(BOOL)debugEnabled;
+ (NSString *)getVersion;

+ (BOOL)isReadyForShowWithStyle:(AppodealShowStyle)showStyle;

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