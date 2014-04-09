//
//  AHKActionSheetViewController.m
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 09-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import "AHKActionSheetViewController.h"
#import "AHKActionSheet.h"

@interface AHKActionSheetViewController ()

@end

@implementation AHKActionSheetViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view = self.actionSheet;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
