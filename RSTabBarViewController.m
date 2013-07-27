//
//  RSTabBarViewController.m
//
//  Created by Rex Sheng on 6/11/12.
//  Copyright (c) 2012 lognllc.com. All rights reserved.
//

#import "RSTabBarViewController.h"
#import "RSTabBar.h"
#import <objc/runtime.h>

#define TABBAR_HEIGHT 44

@implementation RSTabBarViewController
{
	BOOL isTabBarHidden;
}

@dynamic selectedIndex;

- (NSUInteger)selectedIndex
{
	return [_viewControllers indexOfObject:_selectedViewController];
}

- (void)setSelectedIndex:(NSUInteger)aSelectedIndex
{
	if (_viewControllers.count > aSelectedIndex) {
		if (self.tabBar) {
			[self.tabBar.delegate tabBar:self.tabBar didSelectItemAtIndex:aSelectedIndex];
		} else {
			self.selectedViewController = (self.viewControllers)[aSelectedIndex];
		}
	}
}

- (void)setSelectedViewController:(UIViewController *)newC
{
	static dispatch_once_t onceToken;
	static dispatch_group_t group;
	dispatch_once(&onceToken, ^{
		group = dispatch_group_create();
	});
	if (dispatch_group_wait(group, DISPATCH_TIME_NOW)) return;
	
	UIViewController *vc = newC;
	if ([vc isKindOfClass:[UINavigationController class]]) {
		vc = [(UINavigationController *)vc topViewController];
	}
	if ([vc conformsToProtocol:@protocol(RSTabBarModalOnlyTrait)]) {
		[self presentViewController:newC animated:YES completion:nil];
	}
	
	UIViewController *oldC = _selectedViewController;
	if (oldC == newC) return;
	
	_selectedViewController = newC;
	[_selectedViewController setRS_tabBarViewController:self];
	
	if ([self isViewLoaded]) {
		dispatch_group_enter(group);
		[oldC willMoveToParentViewController:nil];
		[self addChildViewController:newC];
		CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, _tabBar.frame.origin.y);
		CGRect newFrame = frame;
		CGRect endFrame = oldC.view.frame;
		
		if ((_transitionStyle & RSTabBarTransitionStyleHorizontal) == RSTabBarTransitionStyleHorizontal) {
			NSInteger oldIndex = [self.viewControllers indexOfObject:oldC];
			NSInteger newIndex = [self.viewControllers indexOfObject:newC];
			endFrame.origin.x = (oldIndex - newIndex) * CGRectGetMaxX(endFrame);
			newFrame.origin.x = -endFrame.origin.x;
		}
		if ((_transitionStyle & RSTabBarTransitionStyleVertical) == RSTabBarTransitionStyleVertical) {
			NSInteger oldIndex = [self.viewControllers indexOfObject:oldC];
			NSInteger newIndex = [self.viewControllers indexOfObject:newC];
			endFrame.origin.y = (oldIndex - newIndex) * CGRectGetMaxY(endFrame);
			newFrame.origin.y = -endFrame.origin.y;
		}
		BOOL fadeInOut = (_transitionStyle & RSTabBarTransitionStyleFade) == RSTabBarTransitionStyleFade;
		
		newC.view.frame = newFrame;
		newC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
		if (fadeInOut && oldC) newC.view.alpha = 0;
		if (oldC) [self transitionFromViewController:oldC toViewController:newC duration:0.25 options:0 animations:^{
			newC.view.frame = frame;
			oldC.view.frame = endFrame;
			if (fadeInOut) {
				newC.view.alpha = 1;
				oldC.view.alpha = 0;
			}
		} completion:^(BOOL finished) {
			[oldC removeFromParentViewController];
			[self.view sendSubviewToBack:newC.view];
			[newC didMoveToParentViewController:self];
			dispatch_group_leave(group);
		}];
		else {
			[self.view addSubview:newC.view];
			[self.view sendSubviewToBack:newC.view];
			[newC didMoveToParentViewController:self];
			dispatch_group_leave(group);
		}
	}
	[_tabBar setSelectedTab:self.selectedIndex animated:oldC != nil];
}

- (void)setViewControllers:(NSArray *)array
{
	if (array != _viewControllers) {
		_viewControllers = array;
		
		if (_viewControllers != nil) {
			[self loadTabs];
		}
	}
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	if (isTabBarHidden != hidden) {
		CGSize size = self.view.bounds.size;
		isTabBarHidden = hidden;
		CGRect frame = _tabBar.frame;
		if (hidden) {
			frame.origin.y = size.height;
		} else {
			frame.origin.y = size.height - frame.size.height;
		}
		_selectedViewController.view.frame = CGRectMake(0, 0, size.width, frame.origin.y);
		[UIView animateWithDuration:animated ? .3 : 0 animations:^{
			_tabBar.frame = frame;
		}];
	}
}

- (void)displayContentController:(UIViewController *)content
{
	[self addChildViewController:content];
	content.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, _tabBar.frame.origin.y);
	content.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:content.view];
	[content didMoveToParentViewController:self];
}

#pragma mark - TabBar Delegate
- (void)tabBar:(RSTabBar *)tabBar didSelectItemAtIndex:(NSUInteger)index
{
	self.selectedViewController = (self.viewControllers)[index];
}

- (void)tabBarDidLoad:(RSTabBar *)tabBar
{
	
}

- (void)loadTabs
{
	NSMutableArray *tabs = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
	for (__strong UIViewController *vc in self.viewControllers) {
		while ([vc isKindOfClass:[UINavigationController class]]) {
			vc = [(UINavigationController *)vc topViewController];
		}
		[tabs addObject:vc.tabBarItem];
	}
	self.tabBar.tabs = tabs;
	[self.tabBar setSelectedTab:self.selectedIndex animated:NO];
}

#pragma mark - View LifeCycle
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	CGRect frame = self.view.bounds;
	if (!_tabBar) {
		RSTabBar *tabBar = [[RSTabBar alloc] initWithFrame:CGRectMake(0, frame.size.height - TABBAR_HEIGHT, frame.size.width, TABBAR_HEIGHT)];
		_tabBar = tabBar;
		_tabBar.delegate = self;
		isTabBarHidden = NO;
		_tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[self loadTabs];
		[self.view addSubview:_tabBar];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	NSUInteger index = self.selectedIndex;
	_selectedViewController = nil;
	[self tabBar:_tabBar didSelectItemAtIndex:index];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.selectedViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self.selectedViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.selectedViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end


@implementation UIViewController (RSTabBar)

static char kRSTabBarViewController;

- (RSTabBarViewController *)RS_tabBarViewController
{
	return objc_getAssociatedObject(self, &kRSTabBarViewController);
}

- (void)setRS_tabBarViewController:(RSTabBarViewController *)vc
{
	objc_setAssociatedObject(self, &kRSTabBarViewController, vc, OBJC_ASSOCIATION_ASSIGN);
}

@end
