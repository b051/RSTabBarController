//
//  RSTabBarViewController.h
//
//  Created by Rex Sheng on 6/11/12.
//  Copyright (c) 2012 lognllc.com. All rights reserved.
//

#import "RSTabBar.h"

typedef NS_OPTIONS(NSUInteger, RSTabBarTransitionStyle) {
	RSTabBarTransitionStyleNone = 0,
	RSTabBarTransitionStyleHorizontal = 1 << 0,
	RSTabBarTransitionStyleVertical = 1 << 1,
	RSTabBarTransitionStyleFade = 1 << 2,
};


@protocol RSTabBarModalOnlyTrait
@end

@interface RSTabBarViewController : UIViewController <RSTabBarDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) RSTabBarTransitionStyle transitionStyle;
@property (nonatomic, readonly, weak) UIViewController *selectedViewController;
@property (nonatomic, readonly, weak) RSTabBar *tabBar;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (id)initWithTabBarClass:(Class)tabBarClass;

@end


@interface UIViewController (RSTabBar)

@property (nonatomic, weak) RSTabBarViewController *RS_tabBarViewController;

@end