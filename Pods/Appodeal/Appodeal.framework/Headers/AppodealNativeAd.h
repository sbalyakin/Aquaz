//
//  AppodealNativeAdModel.h
//  Appodeal
//
//  Created by Stanislav  on 06/11/15.
//  Copyright © 2015 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Appodeal/AppodealImage.h>

@interface AppodealNativeAd : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSString *subtitle;
@property (copy, nonatomic, readonly) NSString *descriptionText;
@property (copy, nonatomic, readonly) NSString *callToActionText;
@property (copy, nonatomic, readonly) NSString *contentRating;
@property (copy, nonatomic, readonly) NSNumber *starRating;

@property (strong, nonatomic, readonly) AppodealImage *image;
@property (strong, nonatomic, readonly) AppodealImage *icon;

- (void)attachToView:(UIView *)view viewController:(UIViewController *)viewController;
- (void)detachFromView;

@end
