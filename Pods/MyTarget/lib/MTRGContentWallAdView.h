//
//  MTRGContentWallAdView.h
//  myTargetSDK, 4.0.17
//
//  Created by Anton Bulankin on 05.12.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTRGBaseNativeAdView.h"
#import "MTRGNativePromoBanner.h"
#import "MTRGNativeImageBanner.h"

@interface MTRGContentWallAdView : MTRGBaseNativeAdView

@property (strong, nonatomic) MTRGNativeImageBanner * imageBanner;

//Изображение
@property (nonatomic, strong, readonly) UIImageView * imageView;

//Отступы
@property (nonatomic) UIEdgeInsets imageMargins;

@end
