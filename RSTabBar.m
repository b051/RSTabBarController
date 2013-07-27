//
//  RSTabBar.m
//
//  Created by Rex Sheng on 6/12/12.
//  Copyright (c) 2012 lognllc.com. All rights reserved.
//

#import "RSTabBar.h"

@implementation RSTabBar
{
	NSUInteger selectedTab;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor blackColor];
		_borderBackgroundWidth = 1;
		selectedTab = NSNotFound;
	}
	return self;
}

- (void)setBorderBackgroundColor:(UIColor *)borderBackgroundColor
{
	self.backgroundColor = borderBackgroundColor;
}

- (UIColor *)borderBackgroundColor
{
	return self.backgroundColor;
}

- (void)setTabBarHeight:(CGFloat)tabBarHeight
{
	_tabBarHeight = tabBarHeight;
	CGRect frame = self.frame;
	frame.origin.y += frame.size.height - tabBarHeight;
	frame.size.height = tabBarHeight;
	self.frame = frame;
}

- (void)setTabs:(NSArray *)tabs
{
	for (UIView *subview in _tabs) {
		[subview removeFromSuperview];
	}
	
	NSMutableArray *newTabs = [NSMutableArray arrayWithCapacity:tabs.count];
	int i = 0;
	CGFloat height = self.bounds.size.height - _borderBackgroundWidth;
	CGFloat perWidth = (self.bounds.size.width - (tabs.count - 1) * _borderBackgroundWidth) / tabs.count;
	CGFloat x = 0;
	for (UITabBarItem *tab in tabs) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(x, _borderBackgroundWidth, perWidth, height);
		x += perWidth + _borderBackgroundWidth;
		button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[button setTitle:tab.title forState:UIControlStateNormal];
		[button setImage:tab.finishedUnselectedImage forState:UIControlStateNormal];
		[button setImage:tab.finishedSelectedImage forState:UIControlStateSelected];
		if ([self.delegate respondsToSelector:@selector(customizeButton:fromTabBarItem:atIndex:)])
			[self.delegate customizeButton:button fromTabBarItem:tab atIndex:i];
		[self addSubview:button];
		[button addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventTouchUpInside];
		[newTabs addObject:button];
		i++;
	}
	_tabs = newTabs;
	if ([self.delegate respondsToSelector:@selector(tabBarDidLoad:)])
		[self.delegate tabBarDidLoad:self];
}

- (void)setSelectedTab:(NSUInteger)tabIndex animated:(BOOL)animated
{
	if (tabIndex != selectedTab) {
		selectedTab = tabIndex;
		UIButton *button = _tabs[selectedTab];
		button.selected = YES;
		for (UIButton *b in _tabs) {
			if (button != b) {
				b.selected = NO;
			}
		}
	}
}

- (void)setSelectedTab:(NSUInteger)tabIndex
{
	[self setSelectedTab:tabIndex animated:YES];
}

- (void)tabSelected:(UIButton *)sender
{
	[self.delegate tabBar:self didSelectItemAtIndex:[self.tabs indexOfObject:sender]];
}

@end
