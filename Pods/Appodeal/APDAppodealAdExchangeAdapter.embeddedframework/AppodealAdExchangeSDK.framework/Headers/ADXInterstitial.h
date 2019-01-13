//
//  ADXInterstitial.h
//  AppodealAdExchangeSDK
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AppodealAdExchangeSDK/ADXRequest.h>


@class ADXInterstitial;

/**
 Interstitial callback handler protocol
 */
@protocol ADXInterstitialDelegate <NSObject>
/**
 Trigger ready event

 @param interstitial Ready instance of interstitial ad
 @param adIdentifier Uniq for ad network identifier
 */
- (void)interstitial:(nonnull ADXInterstitial *)interstitial
    readyToPresentAd:(nonnull NSString *)adIdentifier;
/**
 Trigger fail to load event

 @param interstitial Failed instance of interstitial ad
 @param error Error object that contains information about fail reason
 */
- (void)interstitial:(nonnull ADXInterstitial *)interstitial failedWithError:(nonnull NSError *)error;
/**
 Trigger fail to present event
 
 @param interstitial Failed instance of interstitial ad
 @param error Error object that contains information about fail reason
 */
- (void)interstitial:(nonnull ADXInterstitial *)interstitial failedToPresentWithError:(nonnull NSError *)error;
/**
 Trigger when interstitial present creative

 @param interstitial Presenting instance of interstitial ad
 */
- (void)interstitialWillPresent:(nonnull ADXInterstitial *)interstitial;
/**
 Trigger when interstitial was closed

 @param interstitial Presented instance of interstitial ad
 */
- (void)interstitialDidDismiss:(nonnull ADXInterstitial *)interstitial;
/**
 Trigger when interstitial register user interaction with creative

 @param interstitial Presenting instance of interstitial ad
 */
- (void)interstitialRecieveUserInteraction:(nonnull ADXInterstitial *)interstitial;

@optional
/**
 Trigger when interstitial register completion of reward action in creative

 @param interstitial Presenting interstitial ad
 */
- (void)interstitialFinishRewardAction:(nonnull ADXInterstitial *)interstitial;
@end


/**
 Object to present regular interstitial ad
 */
@interface ADXInterstitial : NSObject
/**
 Callback handler
 */
@property (nonatomic, weak, nullable) id<ADXInterstitialDelegate> delegate;
/**
 Boolean flag indicates ad availability
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;
/**
 Presented ad view. If ad not on screen this property are nil
 */
@property (nonatomic, readonly, nullable) UIView * adView;
/**
 Content of loaded ad
 */
@property (nonatomic, readonly, nullable) NSString * adContent;
/**
 Demand name
 */
@property (nonatomic, readonly, nullable) NSString * demandSource;
/**
 Begin loading of interstitial ad

 @param request Request with mediation specific parameters
 */
- (void)makeRequest:(nonnull ADXRequest *)request;
/**
 Begin presentation of ad if it's available

 @param rootViewController view controller for presentation
 */
- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController;
/**
 Begin presentation of ad if it's available

 @param placement Current active placement
 @param rootViewController view controller for presentation
 */
- (void)presentWithPlacement:(nonnull NSNumber *)placement fromRootViewController:(nonnull UIViewController *)rootViewController;
/**
 Remove all loaded ad data
 */
- (void)invalidate;
@end
