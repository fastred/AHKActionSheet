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

- (UIViewController *)ahk_viewControllerForStatusBarStyle
{
    UIViewController *currentViewController = [self currentViewController];

    while ([currentViewController childViewControllerForStatusBarStyle]) {
        currentViewController = [currentViewController childViewControllerForStatusBarStyle];
    }
    return currentViewController;
}

- (UIViewController *)ahk_viewControllerForStatusBarHidden
{
    UIViewController *currentViewController = [self currentViewController];

    while ([currentViewController childViewControllerForStatusBarHidden]) {
        currentViewController = [currentViewController childViewControllerForStatusBarHidden];
    }
    return currentViewController;
}

- (UIImage *)ahk_snapshot
{
    // source (under MIT license): https://github.com/shinydevelopment/SDScreenshotCapture/blob/master/SDScreenshotCapture/SDScreenshotCapture.m#L35

    CGSize imageSize = CGSizeZero;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.center.x, self.center.y);
    CGContextConcatCTM(context, self.transform);
    CGContextTranslateCTM(context, -self.bounds.size.width * self.layer.anchorPoint.x, -self.bounds.size.height * self.layer.anchorPoint.y);

    // correct for the screen orientation
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        CGContextRotateCTM(context, (CGFloat)M_PI_2);
        CGContextTranslateCTM(context, 0, -imageSize.width);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        CGContextRotateCTM(context, (CGFloat)-M_PI_2);
        CGContextTranslateCTM(context, -imageSize.height, 0);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGContextRotateCTM(context, (CGFloat)M_PI);
        CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
    }

    
    if([self isios6])
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    else
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];

    CGContextRestoreGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - Private
- (BOOL)isios6{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        return NO;
    }else{
        return YES;
    }
    
}

- (UIViewController *)currentViewController
{
    UIViewController *viewController = self.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

@end
