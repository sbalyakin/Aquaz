//
//  MVOfferWallRewardInfo.h
//  MVSDK
//
//  Created by CharkZhang on 2017/3/13.
//  Copyright © 2017年 Mobvista. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVOfferWallRewardInfo : NSObject

/**
 *  The reward name as defined on Self Service
 */
@property (nonatomic, copy  ) NSString  *rewardName;

/**
 *  Amount of reward type given to the user
 */
@property (nonatomic, assign) NSInteger rewardAmount;


@end
