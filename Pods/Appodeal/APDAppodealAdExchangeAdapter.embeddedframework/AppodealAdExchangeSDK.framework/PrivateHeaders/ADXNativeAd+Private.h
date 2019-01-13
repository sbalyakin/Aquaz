//
//  ADXNativeAd+Private.h
//  AppodealAdExchangeSDK
//
//  Created by Lozhkin Ilya on 5/31/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "ADXNativeAd.h"
#import "ADXResponse.h"
#import "ADXAdapterProtocol.h"

@interface ADXNativeAd ()

+ (ADXNativeAd *)nativeAdWithAdapter:(id<ADXNativeAdAdapter>)adapter response:(id<ADXResponse>)response;

@end
