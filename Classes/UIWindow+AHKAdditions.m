//
//  UIWindow+AHKAdditions.m
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 14-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import "UIWindow+AHKAdditions.h"

@implementation UIWindow (AHKAdditions)

#pragma mark - Public

- (UIViewController *)AHKviewControllerForStatusBarStyle
{
    UIViewController *currentViewController = [self currentViewController];

    while ([currentViewController childViewControllerForStatusBarStyle]) {
        currentViewController = [currentViewController childViewControllerForStatusBarStyle];
    }
    return currentViewController;
}

- (UIViewController *)AHKviewControllerForStatusBarHidden
{
    UIViewController *currentViewController = [self currentViewController];

    while ([currentViewController childViewControllerForStatusBarHidden]) {
        currentViewController = [currentViewController childViewControllerForStatusBarHidden];
    }
    return currentViewController;
}

#pragma mark - Private

- (UIViewController *)currentViewController
{
    UIViewController *viewController = self.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

@end
