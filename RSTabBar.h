//
//  RSTabBar.h
//  Network
//
//  Created by Rex Sheng on 6/12/12.
//  Copyright (c) 2012 lognllc.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSTabBar;

@protocol RSTabBarDelegate <NSObject>

- (void)tabBar:(RSTabBar *)tabBar didSelectItemAtIndex:(NSUInteger)index;
- (void)customizeButton:(UIButton *)button fromTabBarItem:(UITabBarItem *)tabBarItem atIndex:(NSUInteger)index;
- (void)tabBarDidLoad:(RSTabBar *)tabBar;

@end


@interface RSTabBar : UIView

@property (nonatomic, unsafe_unretained) id<RSTabBarDelegate> delegate;
@property (nonatomic, strong) NSArray *tabs;

- (void)setSelectedTab:(NSUInteger)tabIndex animated:(BOOL)animated;

@end
