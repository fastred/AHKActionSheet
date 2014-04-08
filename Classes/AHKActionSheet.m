//
//  AHKActionSheet.m
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 08-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AHKActionSheet.h"
#import "UIView+Snapshots.h"
#import "UIImage+ImageEffects.h"

@interface AHKActionSheetViewController : UIViewController
@property (strong, nonatomic) AHKActionSheet *actionSheet;
@end

@implementation AHKActionSheetViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view = self.actionSheet;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end


@interface AHKActionSheetItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (nonatomic) AHKActionSheetButtonType type;
@property (strong, nonatomic) AHKActionSheetHandler handler;
@end

@implementation AHKActionSheetItem
@end


static CGFloat const kCancelButtonHeight = 44.0f;
static CGFloat const kFullAnimationLength = 0.5f;

static CGRect cancelButtonVisibleFrame(void) {
    return CGRectMake(0,
                      CGRectGetMaxY([UIScreen mainScreen].bounds) - kCancelButtonHeight,
                      CGRectGetWidth([UIScreen mainScreen].bounds),
                      kCancelButtonHeight);
}

static CGRect cancelButtonHiddenFrame(void) {
    return CGRectMake(0,
                      CGRectGetMaxY([UIScreen mainScreen].bounds),
                      CGRectGetWidth([UIScreen mainScreen].bounds),
                      kCancelButtonHeight);
}

@interface AHKActionSheet()
@property (strong, nonatomic) NSMutableArray *items;
@property (copy, nonatomic) NSString *title;
@property (weak, nonatomic) UIWindow *previousKeyWindow;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIImageView *blurredBackgroundView;
@property (nonatomic, getter = isVisible) BOOL visible;
@property (strong, nonatomic) UIButton *cancelButton;
@end

@implementation AHKActionSheet

#pragma mark - Init

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _title = title;

        _blurRadius = 16.0f;
        _blurTintColor = [UIColor colorWithWhite:1.0f alpha:0.25f];
        _blurSaturationDeltaFactor = 1.8f;
        _topInset = 200.0f;
    }

    return self;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Properties

- (NSMutableArray *)items
{
    if (!_items) {
        _items = [NSMutableArray array];
    }

    return _items;
}

#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title type:(AHKActionSheetButtonType)type handler:(AHKActionSheetHandler)handler
{
    AHKActionSheetItem *item = [[AHKActionSheetItem alloc] init];
    item.title = title;
    item.type = type;
    item.handler = handler;
    [self.items addObject:item];
}

- (void)show
{
    NSAssert([self.items count] > 0, @"Please add some buttons before calling -show.");

    if (self.isVisible) {
        return;
    }

    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIImage *previousKeyWindowSnapshot = [self.previousKeyWindow snapshotImage];

    AHKActionSheetViewController *actionSheetVC = [[AHKActionSheetViewController alloc] initWithNibName:nil bundle:nil];
    actionSheetVC.actionSheet = self;

    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.window.opaque = NO;
        self.window.rootViewController = actionSheetVC;
    }
    [self.window makeKeyAndVisible];
    self.visible = YES;

    [self setUpBlurredBackgroundWithSnapshot:previousKeyWindowSnapshot];
    [self setUpCancelButton];

    [UIView animateKeyframesWithDuration:kFullAnimationLength delay:0 options:0 animations:^{
        self.blurredBackgroundView.alpha = 1.0f;

        [UIView addKeyframeWithRelativeStartTime:0.3f relativeDuration:0.7f animations:^{
            self.cancelButton.frame = cancelButtonVisibleFrame();
        }];
    } completion:nil];
}

- (void)dismissAnimated:(BOOL)animated
{
    [UIView animateKeyframesWithDuration:kFullAnimationLength delay:0 options:0 animations:^{
        self.blurredBackgroundView.alpha = 0.0f;

        [UIView addKeyframeWithRelativeStartTime:0.3f relativeDuration:0.7f animations:^{
            self.cancelButton.frame = cancelButtonHiddenFrame();
        }];
    } completion:^(BOOL finished) {
        [self.window removeFromSuperview];
        self.window = nil;

        [self.previousKeyWindow makeKeyAndVisible];
    }];
}

#pragma mark - Private

- (void)setUpBlurredBackgroundWithSnapshot:(UIImage *)previousKeyWindowSnapshot
{
    UIImage *blurredViewSnapshot = [previousKeyWindowSnapshot
                                    applyBlurWithRadius:self.blurRadius
                                    tintColor:self.blurTintColor
                                    saturationDeltaFactor:self.blurSaturationDeltaFactor
                                    maskImage:nil];
    self.blurredBackgroundView = [[UIImageView alloc] initWithImage:blurredViewSnapshot];
    self.blurredBackgroundView.frame = self.bounds;
    self.blurredBackgroundView.alpha = 0.0f;
    [self addSubview:self.blurredBackgroundView];
}

- (void)cancelButtonTapped:(id)sender
{
    [self dismissAnimated:YES];
}

- (void)setUpCancelButton
{
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.frame = cancelButtonHiddenFrame();
    self.cancelButton.backgroundColor = self.blurTintColor;
    self.cancelButton.layer.masksToBounds = NO;

    // setup a glow on top of the button
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.cancelButton.layer.bounds];
    self.cancelButton.layer.shadowColor = self.blurTintColor.CGColor;
    self.cancelButton.layer.shadowOffset = CGSizeMake(0.0f, -5.0f);
    self.cancelButton.layer.shadowOpacity = 1.0f;
    self.cancelButton.layer.shadowPath = shadowPath.CGPath;

    [self addSubview:self.cancelButton];
}

@end
