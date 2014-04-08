//
//  AHKViewController.m
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 08-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import "AHKViewController.h"
#import "AHKActionSheet.h"

@interface AHKViewController ()

@end

@implementation AHKViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Actions

- (IBAction)showActionSheetTapped:(id)sender
{
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:NSLocalizedString(@"Test test", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Button 1", nil)
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet) {
                                NSLog(@"Button 1 tapped");
                            }];

    [actionSheet show];
}

@end
