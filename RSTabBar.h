//
//  RSTabBar.h
//
//  Created by Rex Sheng on 6/12/12.
//  Copyright (c) 2012 lognllc.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RSTabBarDelegate;

@interface RSTabBar : UIView

@property (nonatomic, weak) id<RSTabBarDelegate> delegate;
@property (nonatomic) CGFloat tabBarHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIOffset offsetBetweenIconAndText UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *borderBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat borderBackgroundWidth UI_APPEARANCE_SELECTOR;

- (void)setTitleAttributes:(NSDictionary *)attributes forButtonState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (NSDictionary *)titleAttributesForButtonState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (void)setBackgroundImage:(UIImage *)image forButtonState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)backgroundImageForButtonState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (void)setSelectedTab:(NSUInteger)tabIndex animated:(BOOL)animated;
- (void)setTabs:(NSArray *)tabs;

@end

@protocol RSTabBarDelegate <NSObject>
- (void)tabBar:(RSTabBar *)tabBar didSelectItemAtIndex:(NSUInteger)index;
@optional
- (void)tabBarDidLoad:(RSTabBar *)tabBar;

@end
