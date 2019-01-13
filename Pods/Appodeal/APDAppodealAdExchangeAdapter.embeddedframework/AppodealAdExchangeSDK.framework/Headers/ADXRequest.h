//
//  ADXRequest.h
//  AppodealAdExchangeSDK
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppodealAdExchangeSDK/ADXDefines.h>
#import <AppodealAdExchangeSDK/ADXNetworkItem.h>

/**
 Request object that contains necessary information for bidding
 */
@interface ADXRequest : NSObject
/**
 Wanted ad types, ex @[@(ADXAdTypeVideo)]
 */
@property (nonatomic, readonly) NSArray <NSNumber *>* supportedTypes;
/**
 Destination URL to exchange that perform auction
 */
@property (nonatomic, readonly) NSURL * destinationURL;
/**
 Identifier of current segment identifier
 */
@property (nonatomic, readonly) NSNumber * activeSegmentIdentifier;
/**
 Networks config
 */
@property (nonatomic, readonly) NSArray <ADXNetworkItem *> * networks;
/**
 Designated initializer

 @param destinationURL Exchange destanation URL
 @param supportedTypes Supported ad types
 @param activeSegemntIdentifier Identifier of current segment identifier
 @param networks Auction networks
 @return Instance of request
 */
+ (instancetype)requestWithDestinationURL:(NSURL *)destinationURL
                           supportedTypes:(NSArray <NSNumber *>*)supportedTypes
                  activeSegemntIdentifier:(NSNumber *)activeSegemntIdentifier
                                 networks:(NSArray <ADXNetworkItem *> *)networks;

@end
