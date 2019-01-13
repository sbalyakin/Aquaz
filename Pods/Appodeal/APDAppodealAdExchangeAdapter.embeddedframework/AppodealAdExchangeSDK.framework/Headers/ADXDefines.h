//
//  ADXDefines.h
//  AppodealAdExchangeSDK
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ADXLog(...)  ADXSdkLoggingEnabled ? NSLog(__VA_ARGS__) : nil
FOUNDATION_EXPORT NSString * kADXErrorDomain;

FOUNDATION_EXPORT BOOL ADXSdkLoggingEnabled;

typedef NS_ENUM(NSInteger, ADXErrorCode) {
    ADXImpressionError = 1001,
    ADXInteractionError,
    ADXFinishError,
    ADXFillError,
    ADXTimeoutError,
    ADXAdapterDieError,
    ADXAdapterTrackerError,
    ADXUnknownNetworkError,
    ADXUnknownError = 9000
};

typedef NS_ENUM(NSInteger, ADXAdType) {
    ADXAdTypeBanner = 1,
    ADXAdTypeVideo,
    ADXAdTypeNative
};

NSString * ADXAdTypeString(ADXAdType adType, BOOL rewarded, BOOL interstitial);
ADXAdType ADXAdTypeFromString(NSString * adTypeString, BOOL * rewarded, BOOL * interstitial);

