//
//  RFMOrientationManager.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 5/15/14.
//  Copyright (c) 2014 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFMOrientationManager : NSObject
+(RFMOrientationManager *)sharedInstance;
-(UIInterfaceOrientation)getRfmAdOrientation;
-(void)setRfmAdOrientation:(UIInterfaceOrientation)newRfmAdOrientation;
@end
