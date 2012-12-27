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
		selectedTab = NSNotFound;
	}
	return self;
}

- (void)setTabs:(NSArray *)tabs
{
	for (UIView *subview in _tabs) {
		[subview removeFromSuperview];
	}
	
	NSMutableArray *newTabs = [NSMutableArray array];
	int i = 0;
	for (UITabBarItem *tab in tabs) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		if ([self.delegate respondsToSelector:@selector(customizeButton:fromTabBarItem:atIndex:)])
			[self.delegate customizeButton:button fromTabBarItem:tab atIndex:i];
		[self addSubview:button];
		[button addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventTouchUpInside];
		[newTabs addObject:button];
		i++;
	}
	_tabs = newTabs;
	[self setNeedsLayout];
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

- (void)layoutSubviews
{
	CGFloat defaultWidth = self.bounds.size.width / _tabs.count;
	CGFloat x = 0;
	for (UIButton *tab in _tabs) {
		CGRect frame = tab.frame;
		frame.origin.x = x;
		if (!frame.size.width) {
			frame.size.width = defaultWidth;
		}
		x += frame.size.width;
		tab.frame = frame;
	}
}

@end
