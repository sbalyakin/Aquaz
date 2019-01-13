//
//  ADXSdk.h
//  AppodealAdExchangeSDK
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppodealAdExchangeSDK/ADXNetworkProtocol.h>
#import <AppodealAdExchangeSDK/ADXDefines.h>
#import <AppodealAdExchangeSDK/ADXNetworkItem.h>

/**
 Poxy object that provides communcation between bidding and networks adapter
 */
@interface ADXSdk : NSObject
/**
 Identifier of SSP
 */
@property (nonatomic, strong, readwrite, nonnull) NSString * ssp;
/**
 Boolean getter that indicated that sdk ready for auction
 */
@property (nonatomic, assign, readonly, getter=isInitialized) BOOL initialized;
/**
 Enable logging. by default logging disabled
 */
@property (nonatomic, assign, readwrite) BOOL enableLogging;
/**
 Singelton sdk object

 @return Shared instance
 */
+ (nonnull instancetype)sharedSdk;

/**
 Register networks adapters

 @param network Class of network adapter
 */
- (void)registerNetwork:(nonnull Class<ADXNetwork>)network;

/**
 Initialize networks sdk and save network class
 and save network classes for future work.
 Allow multiply calls

 @param networks Networks configuration
 @param completion Block that returned result of initialisation operation
 */
- (void)initialize:(nonnull NSArray <ADXNetworkItem *> *)networks
        completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;

@end
