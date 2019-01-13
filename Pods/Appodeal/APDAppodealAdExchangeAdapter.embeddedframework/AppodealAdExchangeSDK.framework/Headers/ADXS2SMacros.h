//
//  ADXS2SMacros.h
//  AppodealAdExchangeSDK
//
//  Created by Ilia Lozhkin on 7/16/18.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#ifndef ADXS2SMacros_h
#define ADXS2SMacros_h

//  _interfaceName:
//
//  Banner
//  Fullscreen
//  NativeAdService

#define ADXPBS2SAdapterInterface(_adapterName, _interfaceName) \
@interface ADXPB##_adapterName##_interfaceName##Adapter : NSObject <ADX##_interfaceName##Adapter> \
@property (nonatomic, weak) id <ADX##_interfaceName##AdapterDelegate> delegate; \
@end

#define ADXPBS2SAdapterImplementation(_adapterName, _interfaceName, _adNetworkCls) \
@implementation ADXPB##_adapterName##_interfaceName##Adapter \
- (Class)relativeAdNetworkClass { return _adNetworkCls.class; } \
- (NSString *)adContent { return nil; } \
- (UIView *)adView { return nil; } \
- (NSDictionary *)externalBiddingInformationForLoadingParamters:(NSDictionary *)loadingParameters error:(NSError *__autoreleasing *)error { \
NSDictionary *ext = loadingParameters[@"parallel_bidding_ext"]; \
return [ext isKindOfClass:NSDictionary.class] ? ext : nil; } \
- (void)prepareContent:(NSDictionary *)contentInfo { \
NSDictionary * userInfo = @{ NSLocalizedFailureReasonErrorKey : @#_adapterName" Parallel Biddibg adapter not contains embeded renderers!"}; \
NSError * error = [NSError errorWithDomain:kADXErrorDomain code:0 userInfo:userInfo]; \
[self.delegate adapter:self failedToPrepareContentWithError:error]; } \
- (void)presentInContainer:(UIView *)container { /*result unused*/ } \
- (void)present { /*result unused*/ } \
@end

#endif /* ADXS2SMacros_h */
