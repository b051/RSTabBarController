//
//  RSTabBarViewController.h
//  Network
//
//  Created by Rex Sheng on 6/11/12.
//  Copyright (c) 2012 lognllc.com. All rights reserved.
//
#import "RSTabBar.h"

@interface RSTabBarViewController : UIViewController <RSTabBarDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, readonly, strong) UIViewController *selectedViewController;
@property (nonatomic, readonly ,strong) RSTabBar *tabBar;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end


@interface UIViewController (RSTabBar)

- (RSTabBarViewController *)RS_tabBarViewController;
- (void)RS_setTabBarViewController:(RSTabBarViewController *)vc;

@end