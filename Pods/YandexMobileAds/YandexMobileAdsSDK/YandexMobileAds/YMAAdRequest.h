/*
 *  YMAAdRequest.h
 *
 * This file is a part of the AppMetrica.
 *
 * Version for iOS © 2015 YANDEX
 *
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://legal.yandex.com/metrica_termsofuse/
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Ad request contains data for ad targeting.
 */
@interface YMAAdRequest : NSObject

/**
 * Current location.
 */
@property (nonatomic, copy, readonly, nullable) CLLocation *location;

/**
 * Query input from user.
 */
@property (nonatomic, copy, readonly, nullable) NSString *contextQuery;

/**
 * Array of tag strings describing current user context.
 */
@property (nonatomic, copy, readonly, nullable) NSArray *contextTags;

- (instancetype)init __attribute__((unavailable("Use designated initializer")));

/**
 * Returns ad request containg user location, query input and context tags.
 * @param location User location.
 * @param contextQuery Query input from user.
 * @param contextTags Array of tag strings describing current user context.
 *
 * @return Ad request containg user location, query input and context tags.
 */
- (instancetype)initWithLocation:(nullable CLLocation *)location
                    contextQuery:(nullable NSString *)contextQuery
                     contextTags:(nullable NSArray *)contextTags NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END