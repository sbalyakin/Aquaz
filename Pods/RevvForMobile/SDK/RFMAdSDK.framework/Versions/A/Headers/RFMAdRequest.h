//
//  RFMAdRequest.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/13/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

@interface RFMAdRequest : NSObject

@property (nonatomic, strong) NSString *rfmAdServer;
@property (nonatomic, strong) NSString *rfmAdPublisherId;
@property (nonatomic, strong) NSString *rfmAdAppId;

//Optional targeting info for ad request
@property (nonatomic, strong) NSDictionary *targetingInfo;


// The following paramters, if set, provide extra information
// for the ad request. If you happen to have this information, providing it will
// help select better targeted ads and will improve monetization.


// If your application uses CoreLocation you can provide the current coordinates
// to help RFMAd,
//
// For example:
//    myRFMAdRequest.locationLatitude = myCLLocationManager.location.coordinate.latitude;
//    myRFMAdRequest.locationLongitude = myCLLocationManager.location.coordinate.longitude;
@property (assign) double locationLatitude;
@property (assign) double locationLongitude;
//Optional : Set string @"ip" for allowing ip based location detection.
@property (nonatomic, strong) NSString *allowLocationDetectType;


//These optional parameters allow set additional adview configuration parameters

//When the ad is in landing view mode, set the transparency with which
//your background application is visible along the edges and corners of the landing
//view. The default value for this setting is 0.6.
@property (assign) CGFloat landingViewAlpha;

//These optional parameters should be implemented only during testing phase

//This optional parameter specifies the mode in which requests are
//handled. The current supported values are as follows –
//“test” – Test Mode, impressions are not counted
@property (nonatomic, strong) NSString *rfmAdMode;


//This optional parameter only renders a specific ad.
//This setting should only be implemented for test accounts
//while testing the performance of a particular ad.
//Return @"0" if you want this setting to be ignored by the SDK
@property (nonatomic, strong) NSString *rfmAdTestAdId;

//Default = NO. Set YES if you want ad request URL to be printed on console.
@property (assign) BOOL showDebugLogs;

//Use to specify if ad is banner(RFM_ADTYPE_BANNER) or interstitial(RFM_ADTYPE_INTERSTITIAL). Default = banner
@property (nonatomic, retain) NSString *rfmAdType;

- (id)initRequestWithServer:(NSString *)adServer
                   andAppId:(NSString *)appId
                   andPubId:(NSString *)pubId;

@end
