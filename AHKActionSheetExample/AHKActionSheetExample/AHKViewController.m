//
//  AHKViewController.m
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 08-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//
// Example icons' source: http://icons8.com/
// Cover image belongs to Tycho.

#import "AHKViewController.h"
#import "AHKActionSheet.h"

@interface AHKViewController (){}
@property (strong, nonatomic) AHKActionSheet *actionSheet;

@end

@implementation AHKViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Actions

- (IBAction)basicExampleTapped:(id)sender
{
    _actionSheet = [[AHKActionSheet alloc] initWithTitle:NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit?", nil)];

    [_actionSheet addButtonWithTitle:NSLocalizedString(@"Info", nil)
                        identifier:@1
                              image:[UIImage imageNamed:@"Icon1"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheetItem *as) {
                                NSLog(@"selected index %@", as.title);
                            }];

    [_actionSheet addButtonWithTitle:NSLocalizedString(@"Add to Favorites", nil)
                        identifier:@2
                              image:[UIImage imageNamed:@"Icon2"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheetItem *as) {
                                NSLog(@"selected index %@", as.title);
                            }];

//    [actionSheet addButtonWithTitle:NSLocalizedString(@"Share", nil)
//                        identifier:@3
//                              image:[UIImage imageNamed:@"Icon3"]
//                               type:AHKActionSheetButtonTypeDefault
//                            handler:^(AHKActionSheetItem *as) {
//                                NSLog(@"selected index %@", as.title);
//                            }];
//
//    [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete", nil)
//                         identifier:@4
//                              image:[UIImage imageNamed:@"Icon4"]
//                               type:AHKActionSheetButtonTypeDestructive
//                            handler:^(AHKActionSheetItem *as) {
//                                NSLog(@"selected index %@", as.title);
//                            }];

    [_actionSheet show];
}

- (IBAction)advancedExampleTapped:(id)sender
{
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];

    actionSheet.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    actionSheet.blurRadius = 8.0f;
    actionSheet.buttonHeight = 50.0f;
    actionSheet.cancelButtonHeight = 50.0f;
    actionSheet.animationDuration = 0.5f;
    actionSheet.cancelButtonShadowColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    actionSheet.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    actionSheet.selectedBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    UIFont *defaultFont = [UIFont fontWithName:@"Avenir" size:17.0f];
    actionSheet.buttonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                          NSForegroundColorAttributeName : [UIColor whiteColor] };
    actionSheet.disabledButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                  NSForegroundColorAttributeName : [UIColor grayColor] };
    actionSheet.destructiveButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                          NSForegroundColorAttributeName : [UIColor redColor] };
    actionSheet.cancelButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                          NSForegroundColorAttributeName : [UIColor whiteColor] };

    UIView *headerView = [[self class] fancyHeaderView];
    actionSheet.headerView = headerView;

    [actionSheet addButtonWithTitle:NSLocalizedString(@"Info", nil)
                         identifier:@1
                              image:[UIImage imageNamed:@"Icon1"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheetItem *as) {
                                NSLog(@"selected index %@", as.title);
                            }];

    [actionSheet addButtonWithTitle:NSLocalizedString(@"Add to Favorites (disabled)", nil)
                            identifier:@2
                              image:[UIImage imageNamed:@"Icon2"]
                               type:AHKActionSheetButtonTypeDisabled
                            handler:^(AHKActionSheetItem *as) {
                                NSLog(@"selected index %@", as.title);
                            }];

    for (int i = 0; i < 5; i++) {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Share %d", i]
                             identifier:[NSNumber numberWithInt:i]
                                  image:[UIImage imageNamed:@"Icon3"]
                                   type:AHKActionSheetButtonTypeDefault
                                handler:^(AHKActionSheetItem *as) {
                                    NSLog(@"selected index %@", as.title);
                                }];
    }

    [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete", nil)
                         identifier:@1
                              image:[UIImage imageNamed:@"Icon4"]
                               type:AHKActionSheetButtonTypeDestructive
                            handler:^(AHKActionSheetItem *as) {
                                NSLog(@"selected index %@", as.title);
                            }];

    [actionSheet show];
}

#pragma mark - Private

+ (UIView *)fancyHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cover"]];
    imageView.frame = CGRectMake(10, 10, 40, 40);
    [headerView addSubview:imageView];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 200, 20)];
    label1.text = @"Some helpful description";
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont fontWithName:@"Avenir" size:17.0f];
    label1.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label1];

    return  headerView;
}

@end
