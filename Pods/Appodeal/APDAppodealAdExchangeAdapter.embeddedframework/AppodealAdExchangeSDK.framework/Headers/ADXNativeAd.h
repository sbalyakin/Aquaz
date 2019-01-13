//
//  ADXNativeAd.h
//  AppodealAdExchangeSDK
//
//  Created by Lozhkin Ilya on 5/31/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Native ad object
 */
@interface ADXNativeAd : NSObject
/**
 Title of native ad
 */
@property (copy, nonatomic, readonly) NSString *title;
/**
 Description text
 */
@property (copy, nonatomic, readonly) NSString *descriptionText;
/**
 CTA text
 */
@property (copy, nonatomic, readonly) NSString *callToActionText;
/**
 Remote URL to image resource
 */
@property (copy, nonatomic, readonly) NSString *mainImageUrlString;
/**
 Remote URL to icon resource
 */
@property (copy, nonatomic, readonly) NSString *iconImageUrlString;
/**
 Subtitle of native ad
 */
@property (copy, nonatomic, readonly) NSString *subtitle;
/**
 Content rating of ad
 */
@property (copy, nonatomic, readonly) NSString *contentRating;
/**
 Star rating of ad
 */
@property (copy, nonatomic, readonly) NSNumber *starRating;
/**
 Remote URL to video resource
 */
@property (nonatomic, strong, readonly) NSURL *videoUrl;
/**
 Autocache
 */
@property (nonatomic, assign, readonly) BOOL videoAutocacheAllowed;
/**
 Id of active segment
 */
@property (nonatomic, copy) NSNumber *segmentId;
/**
 Id of active placement
 */
@property (nonatomic, copy) NSNumber *placementId;
/**
 Fire impression tracker
 */
- (void)trackImpression;
/**
 Fire interaction tracker
 */
- (void)trackInteraction;
/**
 Fire finish tracker
 */
- (void)trackFinish;

@end
