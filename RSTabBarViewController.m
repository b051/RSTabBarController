//
//  RSTabBarViewController.m
//  Network
//
//  Created by Rex Sheng on 6/11/12.
//  Copyright (c) 2012 lognllc.com. All rights reserved.
//

#import "RSTabBarViewController.h"
#import "RSTabBar.h"
#import <objc/runtime.h>
#import <objc/message.h>


#define TABBAR_HEIGHT 55

@interface RSTabBarViewController () <RSTabBarDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) RSTabBar *tabBar;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *selectedViewController;

@end


@implementation RSTabBarViewController
{
	BOOL visible;
	BOOL isTabBarHidden;
}

@synthesize viewControllers, selectedIndex, tabBar, contentView, selectedViewController;

- (NSUInteger)selectedIndex
{
	return [self.viewControllers indexOfObject:self.selectedViewController];
}

- (void)setSelectedIndex:(NSUInteger)aSelectedIndex
{
	if (self.viewControllers.count > aSelectedIndex) {
		if (self.tabBar) {
			[self.tabBar.delegate tabBar:self.tabBar didSelectItemAtIndex:aSelectedIndex];
		} else {
			self.selectedViewController = (self.viewControllers)[aSelectedIndex];
		}
	}
}

- (void)setSelectedViewController:(UIViewController *)viewController
{
	SEL openInModalSEL = @selector(canOnlyBeOpenedInModal);
	UIViewController *vc = viewController;
	if ([vc isKindOfClass:[UINavigationController class]]) {
		vc = [(UINavigationController *)vc topViewController];
	}
	
	if ([vc respondsToSelector:openInModalSEL]) {
		if (((BOOL (*)(id, SEL))objc_msgSend)(vc, openInModalSEL)) {
			[self presentModalViewController:viewController animated:YES];
			return;
		}
	}
	
	UIViewController *oldVC = selectedViewController;
	if (selectedViewController != viewController) {
		selectedViewController = viewController;
		[selectedViewController RS_setTabBarViewController:self];
		if (!self.childViewControllers && visible) {
			[oldVC viewWillDisappear:NO];
			[selectedViewController viewWillAppear:NO];
		}
		if ([self isViewLoaded])
			[self setContentViewFromViewController:viewController];
		if (!self.childViewControllers && visible) {
			[oldVC viewDidDisappear:NO];
			[selectedViewController viewDidAppear:NO];
		}
		[tabBar setSelectedTab:self.selectedIndex animated:oldVC != nil];
	}
}

- (void)setViewControllers:(NSArray *)array
{
	if (array != viewControllers) {
		viewControllers = array;
		
		if (viewControllers != nil) {
			[self loadTabs];
		}
	}
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	if (isTabBarHidden != hidden) {
		CGSize size = self.view.bounds.size;
		isTabBarHidden = hidden;
		CGRect frame = tabBar.frame;
		if (hidden) {
			frame.origin.y = size.height;
		} else {
			frame.origin.y = size.height - frame.size.height;
		}
		contentView.frame = CGRectMake(0, 0, size.width, frame.origin.y);
		[contentView setNeedsLayout];
		[UIView animateWithDuration:animated ? .3 : 0 animations:^{
			tabBar.frame = frame;
		}];
	}
}

- (void)setContentViewFromViewController:(UIViewController *)viewController
{
	[contentView removeFromSuperview];
	contentView = viewController.view;
	contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, tabBar.frame.origin.y);
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:contentView];
	[self.view sendSubviewToBack:contentView];
}

#pragma mark - TabBar Delegate
- (void)tabBar:(RSTabBar *)tabBar didSelectItemAtIndex:(NSUInteger)index
{
	self.selectedViewController = (self.viewControllers)[index];
}

- (void)customizeButton:(UIButton *)button fromTabBarItem:(UITabBarItem *)tabBarItem atIndex:(NSUInteger)index
{
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
	if (!tabBar) {
		tabBar = [[RSTabBar alloc] initWithFrame:CGRectMake(0, frame.size.height - TABBAR_HEIGHT, frame.size.width, TABBAR_HEIGHT)];
		tabBar.delegate = self;
		isTabBarHidden = NO;
		tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[self loadTabs];
		[self.view addSubview:tabBar];
	}
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	tabBar = nil;
	contentView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	NSUInteger index = self.selectedIndex;
	selectedViewController = nil;
	[self tabBar:tabBar didSelectItemAtIndex:index];
	visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (!self.childViewControllers)
		[selectedViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	if (![self respondsToSelector:@selector(addChildViewController:)])
		[selectedViewController viewDidDisappear:animated];
	visible = NO;
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

- (void)RS_setTabBarViewController:(RSTabBarViewController *)vc
{
	objc_setAssociatedObject(self, &kRSTabBarViewController, vc, OBJC_ASSOCIATION_ASSIGN);
}

@end
