//
//  ADXNetworkProtocol.h
//  AppodealAdExchangeSDK
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppodealAdExchangeSDK/ADXAdapterProtocol.h>

@class ADXSdk;
@protocol ADXNetwork;


@protocol ADXNetwork <NSObject>

+ (NSString *)name;
+ (NSString *)sdkVersion;

@optional

+ (void)startThirdPartySdkSession:(NSDictionary *)parameters
                       completion:(dispatch_block_t)completion;

+ (Class<ADXBannerAdapter>)bannerAdapterClassForSdk:(ADXSdk *)sdk;
+ (Class<ADXFullscreenAdapter>)interstitialAdAdapterClassForSdk:(ADXSdk *)sdk;
+ (Class<ADXFullscreenAdapter>)videoAdapterClassForSdk:(ADXSdk *)sdk;
+ (Class<ADXNativeAdServiceAdapter>)nativeAdAdapterClassForSdk:(ADXSdk *)sdk;

@end
