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
	NSMutableArray *_buttons;
	NSArray *_tabs;
	NSMutableDictionary *backgroundImages;
	NSMutableDictionary *titleAttributes;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor blackColor];
		_borderBackgroundWidth = 1;
		_offsetBetweenIconAndText = UIOffsetMake(0, 6);
		selectedTab = NSNotFound;
	}
	return self;
}

- (void)setBorderBackgroundColor:(UIColor *)borderBackgroundColor
{
	self.backgroundColor = borderBackgroundColor;
}

- (void)setBackgroundImage:(UIImage *)image forButtonState:(UIControlState)state
{
	if (!backgroundImages) {
		backgroundImages = [@{} mutableCopy];
	}
	backgroundImages[@(state)] = image;
}

- (UIImage *)backgroundImageForButtonState:(UIControlState)state
{
	return backgroundImages[@(state)];
}

- (void)setTitleAttributes:(NSDictionary *)attributes forButtonState:(UIControlState)state
{
	if (!titleAttributes) {
		titleAttributes = [@{} mutableCopy];
	}
	titleAttributes[@(state)] = attributes;
}

- (NSDictionary *)titleAttributesForButtonState:(UIControlState)state
{
	return titleAttributes[@(state)];
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

- (void)layoutSubviews
{
	int i = 0;
	CGFloat height = self.bounds.size.height - _borderBackgroundWidth;
	CGFloat perWidth = (self.bounds.size.width - (_buttons.count - 1) * _borderBackgroundWidth) / _buttons.count;
	CGFloat x = 0;
	for (UIButton *button in _buttons) {
		button.frame = CGRectMake(x, _borderBackgroundWidth, perWidth, height);
		x += perWidth + _borderBackgroundWidth;
		[button setBackgroundImage:[self backgroundImageForButtonState:UIControlStateNormal] forState:UIControlStateNormal];
		[button setBackgroundImage:[self backgroundImageForButtonState:UIControlStateSelected] forState:UIControlStateSelected];
		NSDictionary *attributes = [self titleAttributesForButtonState:UIControlStateNormal];
		if (attributes) {
			[button setAttributedTitle:[[NSAttributedString alloc] initWithString:[_tabs[i] title] attributes:attributes] forState:UIControlStateNormal];
		}
		attributes = [self titleAttributesForButtonState:UIControlStateSelected];
		if (attributes) {
			[button setAttributedTitle:[[NSAttributedString alloc] initWithString:[_tabs[i] title] attributes:attributes] forState:UIControlStateSelected];
		}
		CGFloat spacing = self.offsetBetweenIconAndText.vertical;
		CGFloat x = self.offsetBetweenIconAndText.horizontal / 2;
		// get the size of the elements here for readability
		CGSize imageSize = button.imageView.frame.size;
		CGSize titleSize = button.titleLabel.frame.size;
		
		// lower the text and push it left to center it
		button.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageSize.width + x), -(imageSize.height + spacing), 0);
		
		// the text width might have changed (in case it was shortened before due to
		// lack of space and isn't anymore now), so we get the frame size again
		titleSize = button.titleLabel.frame.size;
		
		// raise the image and push it right to center it
		button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, -(titleSize.width + x));
		i++;
	}
}

- (void)setTabs:(NSArray *)tabs
{
	_tabs = tabs;
	for (UIView *subview in _buttons) {
		[subview removeFromSuperview];
	}
	NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:_tabs.count];
	for (UITabBarItem *tab in _tabs) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:tab.title forState:UIControlStateNormal];
		[button setImage:tab.finishedUnselectedImage forState:UIControlStateNormal];
		[button setImage:tab.finishedSelectedImage forState:UIControlStateSelected];
		[self addSubview:button];
		[button addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventTouchUpInside];
		[buttons addObject:button];
	}
	_buttons = buttons;
	[self setNeedsLayout];
}

- (void)setSelectedTab:(NSUInteger)tabIndex animated:(BOOL)animated
{
	if (tabIndex != selectedTab) {
		selectedTab = tabIndex;
		UIButton *button = _buttons[selectedTab];
		button.selected = YES;
		for (UIButton *b in _buttons) {
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
	[self.delegate tabBar:self didSelectItemAtIndex:[_buttons indexOfObject:sender]];
}

@end
