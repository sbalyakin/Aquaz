//
//  MTRGNativeCommonAd.h
//  myTargetSDK, 4.0.17
//
//  Created by Anton Bulankin on 22.12.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import "MTRGNativeCommonAdBanner.h"
#import "MTRGNativeBaseAd.h"
#import <Foundation/Foundation.h>


@class MTRGNativeCommonAd;

@protocol MTRGNativeCommonAdDelegate <NSObject>

-(void)onLoadWithNativeCommonBanner:(MTRGNativeCommonAdBanner *)commonBanner commonAd:(MTRGNativeCommonAd *)commonAd;
-(void)onNoAdWithReason:(NSString *)reason commonAd:(MTRGNativeCommonAd *)commonAd;

@optional

-(void)onAdClickWithNativeCommonAd:(MTRGNativeCommonAd *)commonAd;

@end


@interface MTRGNativeCommonAd : MTRGNativeBaseAd

-(instancetype) initWithSlotId:(NSString*)slotId;
//Делегат
@property (weak, nonatomic) id<MTRGNativeCommonAdDelegate> delegate;
//Загрузить картинку в UIImageView
-(void) loadImageToView:(UIImageView*) imageView;
//Загрузить Иконку в UIImageView
-(void) loadIconToView:(UIImageView*) imageView;

@property (strong, nonatomic, readonly) MTRGNativeCommonAdBanner * banner;

@end
