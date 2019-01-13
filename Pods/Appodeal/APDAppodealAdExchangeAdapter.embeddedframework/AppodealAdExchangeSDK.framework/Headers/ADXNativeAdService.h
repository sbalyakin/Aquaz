//
//  ADXNativeService.h
//  AppodealAdExchangeSDK
//
//  Created by Lozhkin Ilya on 5/31/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppodealAdExchangeSDK/ADXRequest.h>
#import <AppodealAdExchangeSDK/ADXNativeAd.h>


@class ADXNativeAdService;

/**
 Native ad service callback handler
 */
@protocol ADXNativeAdServiceDelegate <NSObject>
/**
 Called if any error occure due to auction

 @param service Failed service
 @param error Error object
 */
- (void)service:(ADXNativeAdService *)service failedToLoadWithError:(NSError *)error;
/**
 Called auction finish with valid bid

 @param service Succesful service
 @param nativeAds Array of ready to present native ads
 */
- (void)service:(ADXNativeAdService *)service didLoadNativeAds:(NSArray <ADXNativeAd *> *)nativeAds;
@end

/**
 Native service that provide auctions and validate win bids.
 */
@interface ADXNativeAdService : NSObject
/**
 Callback handler
 */
@property (nonatomic, weak, nullable) id<ADXNativeAdServiceDelegate> delegate;
/**
 Demand name
 */
@property (nonatomic, readonly, nullable) NSString * demandSource;
/**
 Make request to exchange backend. Provide bidding information from
 sdk networks and embedded display manager (NAST)

 @param request Request object
 */
- (void)makeRequest:(nonnull ADXRequest *)request;
@end
