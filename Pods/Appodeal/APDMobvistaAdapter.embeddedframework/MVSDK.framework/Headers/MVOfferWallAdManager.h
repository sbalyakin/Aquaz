//
//  MVOfferWallAdManager.h
//  MVSDK
//
//  Created by CharkZhang on 16/11/7.
//
#define MVOfferWallSDKVersion @"3.8.1"

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, MVOfferWallAdCategory) {
    MVOFFERWALL_AD_CATEGORY_ALL  = 0,
    MVOFFERWALL_AD_CATEGORY_GAME = 1,
    MVOFFERWALL_AD_CATEGORY_APP  = 2,
};

@class MVOfferWallAdManager;

#pragma mark - MVOfferWallAdManagerDelegate

/**
 *  This protocol defines a listener for ad offer wall load events.
 */
@protocol MVOfferWallAdLoadDelegate <NSObject>

@optional
/**
 *  Sent when the ad is successfully load , and is ready to be displayed
 */
- (void) onOfferwallLoadSuccess DEPRECATED_ATTRIBUTE;
- (void) onOfferwallLoadSuccess:(MVOfferWallAdManager *_Nonnull)adManager;


/**
 *  Sent when there was an error loading the ad.
 *
 *  @param error An NSError object with information about the failure.
 */
- (void) onOfferwallLoadFail:(nonnull NSError *)error DEPRECATED_ATTRIBUTE;
- (void) onOfferwallLoadFail:(nonnull NSError *)error adManager:(MVOfferWallAdManager *_Nonnull)adManager;

@end


/**
 *  This protocol defines a listener for ad offer wall show events.
 */
@protocol MVOfferWallAdShowDelegate <NSObject>

@optional
/**
 *  Sent when the offer wall success to open
 */
- (void) offerwallShowSuccess DEPRECATED_ATTRIBUTE;
- (void) offerwallShowSuccess:(MVOfferWallAdManager *_Nonnull)adManager;

/**
 *  Sent when the offer wall failed to open for some reason
 *
 *  @param error An NSError object with information about the failure.
 */
- (void) offerwallShowFail:(nonnull NSError *)error DEPRECATED_ATTRIBUTE;
- (void) offerwallShowFail:(nonnull NSError *)error adManager:(MVOfferWallAdManager *_Nonnull)adManager;


/**
 *  Sent when the offer wall has been clesed from being open, and control will return to your app
 */
- (void) onOfferwallClosed DEPRECATED_ATTRIBUTE;
- (void) onOfferwallClosed:(MVOfferWallAdManager *_Nonnull)adManager;



/**
 *  Immediately sent after the user to complete the task, should be rewarded
 *
 *  @param rewards   an array whose element is a object of MVOfferWallRewardInfo, which containing the info that should be given to your user.
 *
 */
- (void) onOfferwallCreditsEarnedImmediately:(nullable NSArray *)rewards DEPRECATED_ATTRIBUTE;
- (void) onOfferwallCreditsEarnedImmediately:(nullable NSArray *)rewards adManager:(MVOfferWallAdManager *_Nonnull)adManager;



/**
 *  Sent after the offer wall has been clicked by a user.
 */
- (void) onOfferwallAdClick DEPRECATED_ATTRIBUTE;
- (void) onOfferwallAdClick:(MVOfferWallAdManager *_Nonnull)adManager;



@end


/**
 *  This protocol defines a listener for queryRewards events.
 */
@protocol MVOfferWallQueryRewardsDelegate <NSObject>

@optional
/**
 *  Sent after developer called ' queryRewardsWithDelegate: ', if the user to complete the task, should be rewarded
 *
 *  @param rewards   an array whose element is a object of MVOfferWallRewardInfo, which containing the info that should be given to your user.
 */
- (void) onOfferwallCreditsEarned:(nullable NSArray *)rewards DEPRECATED_ATTRIBUTE;
- (void) onOfferwallCreditsEarned:(nullable NSArray *)rewards adManager:(MVOfferWallAdManager *_Nonnull)adManager;



@end




#pragma mark - MVOfferWallAdManager

@interface MVOfferWallAdManager : NSObject

@property (nonatomic, readonly)   NSString * _Nonnull currentUnitId;
@property (nonatomic, readonly)   NSString * _Nonnull currentUserId;

/**
 *  Initialize the native ads manager.
 *
 *  @param unitId         The id of the ad unit. You can create your unit id from our Portal.
 *  @param userId       - The user's unique identifier in your system.
 *  @param adCategory     Decide what kind of ads you want to retrieve. Games, apps or all of them. The default is All.
 */
- (nonnull instancetype)initWithUnitID:(nonnull NSString *)unitId
                                userID:(nullable NSString *)userId
                            adCategory:(MVOfferWallAdCategory)adCategory;

/**
 *  Called when load the offer wall
 *
 *  @param unitId   the unitId string of the offer wall that was loaded.
 *  @param delegate reference to the object that implements MVOfferWallAdLoadDelegate protocol; will receive load events for the given unitId.
 */
- (void)loadWithDelegate:(nullable id <MVOfferWallAdLoadDelegate>) delegate;

/**
 *  Called when show the offer wall
 *
 *  @param delegate       reference to the object that implements MVOfferWallAdShowDelegate protocol; will receive show events for the given unitId.
 *  @param viewController The UIViewController that will be used to present Offer Wall Controller. If not set, it will be the root viewController of your current UIWindow. But it may failed to present our offerwall view controller if your rootViewController is presenting other view controller. So set this property is necessary.

 */
- (void)showWithDelegate:(nullable id <MVOfferWallAdShowDelegate>)delegate presentingViewController:(nullable UIViewController *)viewController;


/**
 *  Called when show the offer wall
 *
 *  @param delegate       reference to the object that implements MVOfferWallAdShowDelegate protocol; will receive show events for the given unitId.

 @param unitId The id of the ad unit. You can create your unit id from our Portal.
 @param navController The UINavigationController that will be used to push Offer Wall Controller. If not set, it will be the root viewController of your current UIWindow. But it may failed to push our OfferWall view controller if your rootViewController is not a navigation controller. So set this property is necessary.
 */
- (void)showWithDelegate:(nullable id <MVOfferWallAdShowDelegate>)delegate
  withNavigationController:(nullable UINavigationController *)navController;

/**
 *  Tips when going to close the offer wall
 *
 *  @param alertContent The content of tips
 *  @param leftTitle    The description of leftTitle
 *  @param rightTitle   The description of rightTitle
 */
- (void)setAlertTipsWhenVideoClosed:(nullable NSString *)alertContent leftButtonTitle:(nullable NSString*)leftTitle rightButtonTitle:(nullable NSString*)rightTitle;

/** 
 *  Called when want to determine whether there are new points appear
 *  Recommended to called frequently for get user Rewards as soon as possible.
 */
- (void)queryRewardsWithDelegate:(nullable id <MVOfferWallQueryRewardsDelegate>)delegate;





/**
 *  Set the offer wall's navigation bar's title.
 *
 *  @param title The title of the navigation bar of offer wall.
 *  @param color The title color of the navigation bar of offer wall.
 */
- (void)setOfferWallTitle:(nonnull NSString *)title
               titleColor:(nonnull UIColor *)color;

/**
 *  Set the offer wall's navigation bar's tint color.
 *
 *  @param color The tint color of the navigation bar of offer wall.
 */
- (void)setOfferWallNavBarTintColor:(nonnull UIColor *)color;

/**
 *  Set the offer wall's navigation bar's background image.
 *
 *  @param image The background image of the navigation bar of offer wall.
 */
- (void)setOfferWallNavBarBackgroundImage:(nonnull UIImage *)image;

/**
 *  A custom image displayed in the center of the offer wall's navigation bar.
 *
 *  @param image The title image of the navigation bar of offer wall.
 */
- (void)setOfferWallTitleImage:(nonnull UIImage *)image;

/**
 *  Custom the image of the close button displayed on the right of the offer wall's navigation bar.
 *
 *  @param image            The image of the close button on state UIControlStateNormal.
 *  @param highlightedImage The image of the close button on state UIControlStateHighlighted.
 */
- (void)setOfferWallCloseButtonImage:(nonnull UIImage *)image
                    highlightedImage:(nullable UIImage *)highlightedImage;



@end
