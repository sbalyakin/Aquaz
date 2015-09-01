//
//  MTRGNativeViewsFactory.h
//  myTargetSDK, 4.0.17
//
//  Created by Anton Bulankin on 17.11.14.
//  Copyright (c) 2014 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "MTRGNativeImageBanner.h"
#import "MTRGNativeTeaserBanner.h"
#import "MTRGNativePromoBanner.h"
#import "MTRGNativeAppwallBanner.h"

#import "MTRGNewsFeedAdView.h"
#import "MTRGChatListAdView.h"
#import "MTRGContentStreamAdView.h"
#import "MTRGContentWallAdView.h"

#import "MTRGAppwallBannerAdView.h"
#import "MTRGAppwallAdView.h"

@interface MTRGNativeViewsFactory : NSObject

//Тизер с кнопкой
+(MTRGNewsFeedAdView *) createNewsFeedViewWithBanner:(MTRGNativeTeaserBanner *)teaserBanner;
//Тизер
+(MTRGChatListAdView *) createChatListViewWithBanner:(MTRGNativeTeaserBanner *)teaserBanner;
//Промо
+(MTRGContentStreamAdView *) createContentStreamViewWithBanner:(MTRGNativePromoBanner *)promoBanner;
//Картинка
+(MTRGContentWallAdView *) createContentWallViewWithBanner:(MTRGNativeImageBanner *)imageBanner;

//App-wall-баннер
+(MTRGAppwallBannerAdView *) createAppWallBannerViewWithBanner:(MTRGNativeAppwallBanner *) appWallBanner;
//App-wall-таблица
+(MTRGAppwallAdView *) createAppWallAdViewWithBanners:(NSArray*)banners;

@end
