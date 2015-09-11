//
//  RFMAdConstants.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/13/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

#ifndef RFMAdSDK_RFMAdConstants_h
#define RFMAdSDK_RFMAdConstants_h

#define RFM_AD_FRAME_OF_SIZE(w,h) CGRectMake(0,0,w,h)

#define RFM_AD_SET_CENTER(CENTER_X, CENTER_Y) CGPointMake(CENTER_X,CENTER_Y)

//#define RFM_AD_SET_CENTER(AD_WIDTH,AD_HEIGHT, WD_OFFSET, HT_OFFSET) CGPointMake(CGRectGetMidX([[UIScreen mainScreen] bounds])+WD_OFFSET,(AD_HEIGHT/2)+HT_OFFSET)

#define RFM_STATUS_BAR_OFFSET 20.0f

#pragma mark - RFM Ad Default Sizes
#define RFM_AD_IPHONE_DEFAULT_WIDTH 320
#define RFM_AD_IPHONE_DEFAULT_HEIGHT 50
#define RFM_AD_IPAD_DEFAULT_WIDTH 300
#define RFM_AD_IPAD_DEFAULT_HEIGHT 250

#pragma mark - RFM AdType information

#define RFM_ADTYPE_BANNER @"1"         //Type 1 = Banner
#define RFM_ADTYPE_INTERSTITIAL @"2"   //Type 2 = Interstitial





#pragma mark - RFM Error Reasons


#endif
