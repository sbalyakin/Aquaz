//
//  ADXAdapterProtocol.h
//  AppodealAdExchangeSDK
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol ADXAdapter;
@protocol ADXFullscreenAdapter;
@protocol ADXBannerAdapter;
@protocol ADXNativeAdServiceAdapter;


/**
 Parent adapter delegate protocol
 */
@protocol ADXAdapterDelegate <NSObject>
/**
 Call when adapter prepare content and ready for present ad

 @param adapter Ready adapter
 */
- (void)adapterPreparedContent:(id<ADXAdapter>)adapter;
/**
 Call when adapter failed with error

 @param adapter Ready adapter
 @param error Error object
 */
- (void)adapter:(id<ADXAdapter>)adapter failedToPrepareContentWithError:(NSError *)error;
/**
 Call when adapter failed to present ad

 @param adapter Adapter that try to present ad
 @param error Erroe object
 */
- (void)adapter:(id<ADXAdapter>)adapter failedToPresentAdWithError:(NSError *)error;
@end

/**
 Parent adapter protocol for get bidding info
 */
@protocol ADXAdapter <NSObject>
/**
 Callback handler object
 */
@property (nonatomic, weak) id<ADXAdapterDelegate> delegate;
/**
 Relative ad network class

 @return Class of relative ad network
 */
- (Class)relativeAdNetworkClass;
/**
 Call this method if adapter need to prepare content
 
 @param contentInfo Custom content info
 */
- (void)prepareContent:(NSDictionary *)contentInfo;
/**
 Getter for raw ad content data string

 @return raw ad content data string
 */
- (NSString *)adContent;

@optional
/**
 Transfoms and populate adunit information for auction
 Need to implement if Third party SDK contains several info
 that Appodeal Ad Exchange SDK doesn't have
 
 @param loadingParameters Recieved information
 @param error Autoreleasing error
 @return Prepared info dictionary
 */
- (NSDictionary *)externalBiddingInformationForLoadingParamters:(NSDictionary *)loadingParameters error:(NSError **)error;

@end


/**
 Banner adapter protocol delegate for rendering inline banner ad
 */
@protocol ADXBannerAdapterDelegate <ADXAdapterDelegate>
/**
 Return nonnul root view controller for presenting product page
 and tracking viewability

 @param adapter Current presentig adapter
 @return Nonnul instance root view controller that view is superview of banner
 */
- (UIViewController *)rootViewControllerForAdapter:(id<ADXBannerAdapter>)adapter;
/**
 Called when user tap on banner

 @param adapter Current presentig adapter
 */
- (void)adapterRegisterUserInteraction:(id<ADXBannerAdapter>)adapter;
@end


/**
  Banner adapter protocol for rendering inline banner ad
 */
@protocol ADXBannerAdapter <ADXAdapter>
/**
 Callback handler
 */
@property (nonatomic, weak) id <ADXBannerAdapterDelegate> delegate;
/**
 Call this method to start rendering banner ad
 @param container Container for presenting ad view
 */
- (void)presentInContainer:(UIView *)container;
@optional
/**
 Remove banner content
 */
- (void)invalidate;
@end

/**
 Fullscreen adapter protocol delegate for rendering banner and video ad
 */
@protocol ADXFullscreenAdapterDelegate <ADXAdapterDelegate>
/**
 Return nonnul root view controller for presenting ad content
 and tracking viewability

 @param adapter Current presenting adapter
 @return Nonnul instance root view controller
 */
- (UIViewController *)rootViewControllerForAdapter:(id<ADXFullscreenAdapter>)adapter;
/**
 Called when adapter will present screen

 @param adapter Current presenting adapter
 */
- (void)adapterWillPresent:(id<ADXFullscreenAdapter>)adapter;
/**
 Called when adapter dissmiss ad screen

 @param adapter Current presenting adapter
 */
- (void)adapterDidDissmiss:(id<ADXFullscreenAdapter>)adapter;
/**
 Called when user interact with adapter

 @param adapter Current presenting adapter
 */
- (void)adapterRegisterUserInteraction:(id<ADXFullscreenAdapter>)adapter;
/**
 Adapter finish reward action (video was fully watched, playable ad complete, etc)

 @param adapter Current presenting adapter
 */
- (void)adapterFinishRewardAction:(id<ADXFullscreenAdapter>)adapter;
@end


/**
 Adapter protocol for rendering fullscreen banner or video ad
 */
@protocol ADXFullscreenAdapter <ADXAdapter>
/**
 Callback handler
 */
@property (nonatomic, weak) id <ADXFullscreenAdapterDelegate> delegate;
/**
 Getter for presented adView
 
 @return presented adView
 */
- (UIView *)adView;
/**
 Call this method to start present ad
 */
- (void)present;

@optional
/**
 Boolean flag that indicates adapter should perform reward action
 */
@property (nonatomic, assign, readwrite) BOOL rewarded;
/**
 Call this method to destroy ad
 */
- (void)invalidate;

@end

@protocol ADXNativeAdAdapter <NSObject>

@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSString *descriptionText;
@property (copy, nonatomic, readonly) NSString *callToActionText;

@property (copy, nonatomic, readonly) NSString *mainImageUrlString;
@property (copy, nonatomic, readonly) NSString *iconImageUrlString;

@property (assign, nonatomic, readonly) CGSize mainImageSize;
@property (assign, nonatomic, readonly) CGSize iconImageSize;

@optional

@property (copy, nonatomic, readonly) NSString *subtitle;
@property (copy, nonatomic, readonly) NSString *contentRating;
@property (copy, nonatomic, readonly) NSNumber *starRating;

@property (nonatomic, strong, readonly) NSURL * videoUrl;
@property (nonatomic, assign, readonly) BOOL videoAutocacheAllowed;

- (void)trackImpression;
- (void)trackInteraction;
- (void)trackFinish;

@end

@protocol ADXNativeAdServiceAdapterDelegate <ADXAdapterDelegate>

- (void)service:(id<ADXNativeAdServiceAdapter>)service didLoadNativeAds:(NSArray <id<ADXNativeAdAdapter>> *)nativeAds;

@end

@protocol ADXNativeAdServiceAdapter <ADXAdapter>

@property (nonatomic, weak) id <ADXNativeAdServiceAdapterDelegate> delegate;

@end
