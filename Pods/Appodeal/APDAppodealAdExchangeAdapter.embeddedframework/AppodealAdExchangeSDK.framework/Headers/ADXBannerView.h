//
//  ADXBannerView.h
//  AppodealAdExchangeSDK
//
//  Created by Stas Kochkin on 10/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppodealAdExchangeSDK/ADXRequest.h>


@class ADXBannerView;

/**
 Banner view callback handler protocol
 */
@protocol ADXBannerDelegate <NSObject>
/**
 Called when banner view ready for present

 @param bannerView Ready for present instance of ADXBannerView
 @param adIdentifier Uniq ad identifier
 */
- (void)bannerView:(nonnull ADXBannerView *)bannerView
  readyToPresentAd:(nonnull NSString *)adIdentifier;
/**
 Called in case if banner view failed to load

 @param bannerView Failed instance of banner view
 @param error Error object
 */
- (void)bannerView:(nonnull ADXBannerView *)bannerView failedWithError:(nonnull NSError *)error;
/**
 Called when user interact with banner

 @param bannerView Ready banner view
 */
- (void)bannerViewRecieveUserInteraction:(nonnull ADXBannerView *)bannerView;
@end

/**
 View for present inline banner ad
 */
@interface ADXBannerView : UIView
/**
 Calback handler
 */
@property (nonatomic, weak, nullable) id<ADXBannerDelegate> delegate;
/**
 Root view controller for present modal controllers and
 viewability tracking
 */
@property (nonatomic, weak, nullable) IBOutlet UIViewController * rootViewController;
/**
 Content of loaded ad
 */
@property (nonatomic, readonly, nullable) NSString * adContent;
/**
 Demand name
 */
@property (nonatomic, readonly, nullable) NSString * demandSource;
/**
 Getter that indicates that ad ready or not
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;
/**
 Call this method to perform auction

 @param request Reuest object
 */
- (void)makeRequest:(nonnull ADXRequest *)request;
/**
 Call this method to present ad
 */
- (void)present;
/**
 Call this method to present ad

 @param placement Current active placement
 */
- (void)presentForPlacement:(nonnull NSNumber *)placement;
/**
 Fire imppression tracker
 */
- (void)trackImpression;
/**
 Call this method to clear ad
 */
- (void)invalidate;
@end
