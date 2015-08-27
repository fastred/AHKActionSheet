//
//  AHKActionSheetViewController.m
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 09-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import "AHKActionSheetViewController.h"
#import "AHKActionSheet.h"
#import "UIWindow+AHKAdditions.h"

@interface AHKActionSheetViewController ()
@property (nonatomic) BOOL viewAlreadyAppear;
@end

@implementation AHKActionSheetViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.actionSheet];
    self.actionSheet.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.viewAlreadyAppear = YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    self.actionSheet.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate
{
    // doesn't allow autorotation after the view did appear (rotation messes up a blurred background)
    return !self.viewAlreadyAppear;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
#if defined(AHK_APP_EXTENSIONS)
    return [self.actionSheet.viewController preferredStatusBarStyle];
#else
    UIWindow *window = self.actionSheet.previousKeyWindow;
    if (!window) {
      window = [[UIApplication sharedApplication].windows firstObject];
    }
    return [[window ahk_viewControllerForStatusBarStyle] preferredStatusBarStyle];
#endif
}

- (BOOL)prefersStatusBarHidden
{
#if defined(AHK_APP_EXTENSIONS)
    return [self.actionSheet.viewController prefersStatusBarHidden];
#else
    UIWindow *window = self.actionSheet.previousKeyWindow;
    if (!window) {
      window = [[UIApplication sharedApplication].windows firstObject];
    }
    return [[window ahk_viewControllerForStatusBarStyle] prefersStatusBarHidden];
#endif
}

@end
