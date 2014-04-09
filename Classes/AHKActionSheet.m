//
//  AHKActionSheet.m
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 08-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AHKActionSheet.h"
#import "AHKActionSheetViewController.h"
#import "UIView+Snapshots.h"
#import "UIImage+ImageEffects.h"


@interface AHKActionSheetItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (nonatomic) AHKActionSheetButtonType type;
@property (strong, nonatomic) AHKActionSheetHandler handler;
@end

@implementation AHKActionSheetItem
@end


static CGFloat const kCancelButtonHeight = 44.0f;
static CGFloat const kFullAnimationLength = 0.5f;
static CGFloat const kTopInset = 200.0f;
static CGFloat kBlurFadeRangeSize = 200.0f;
static NSString * const kCellIdentifier = @"Cell";

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

static UIEdgeInsets tableViewHiddenEdgeInsets(void) {
    return UIEdgeInsetsMake(CGRectGetHeight([UIScreen mainScreen].bounds), 0, 0, 0);
}

@interface AHKActionSheet() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *items;
@property (copy, nonatomic) NSString *title;
@property (weak, nonatomic) UIWindow *previousKeyWindow;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIImageView *blurredBackgroundView;
@property (strong, nonatomic) UITableView *tableView;
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
        _buttonHeight = 60.0f;
    }

    return self;
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    AHKActionSheetItem *item = self.items[indexPath.row];
    cell.textLabel.text = item.title;
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AHKActionSheetItem *item = self.items[indexPath.row];
    [self dismissAnimated:YES duration:kFullAnimationLength completion:item.handler];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.buttonHeight;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self fadeBlurOnScrollToTop];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    static CGFloat autoDismissOffset = 80.0f;
    static CGFloat flickDownHandlingOffset = 20.0f;
    static CGFloat flickDownMinVelocity = 2000.0f;
    CGPoint scrollVelocity = [scrollView.panGestureRecognizer velocityInView:self];

    BOOL viewFlickedDown = scrollVelocity.y > flickDownMinVelocity && scrollView.contentOffset.y < -kTopInset - flickDownHandlingOffset;
    if (viewFlickedDown) {
        CGFloat duration = 0.1f;
        [self dismissAnimated:YES duration:duration completion:nil];
        self.tableView.hidden = YES; // hide the tableView because animation isn't pretty
    } else if (scrollView.contentOffset.y < -kTopInset - autoDismissOffset) {
        [self dismissAnimated:YES duration:kFullAnimationLength completion:nil];
    }
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
    [self setUpTableView];


    self.tableView.contentInset = tableViewHiddenEdgeInsets();

    [UIView animateKeyframesWithDuration:kFullAnimationLength delay:0 options:0 animations:^{
        self.blurredBackgroundView.alpha = 1.0f;

        [UIView addKeyframeWithRelativeStartTime:0.3f relativeDuration:0.7f animations:^{
            self.cancelButton.frame = cancelButtonVisibleFrame();
            self.tableView.contentInset = UIEdgeInsetsMake(kTopInset, 0, 0, 0);
        }];
    } completion:nil];
}

- (void)dismissAnimated:(BOOL)animated
{
    [self dismissAnimated:animated duration:kFullAnimationLength completion:nil];
}

#pragma mark - Private

- (void)dismissAnimated:(BOOL)animated duration:(CGFloat)duration completion:(AHKActionSheetHandler)completionHandler
{
    // delegate isn't needed anymore because tableView will be hidden
    self.tableView.delegate = nil;

    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations:^{
        self.blurredBackgroundView.alpha = 0.0f;

        // do all animations simultaneously when the duration is smaller than the default
        CGFloat relativeStartTime = duration == kFullAnimationLength ? 0.3f : 0.0f;
        CGFloat relativeDuration = duration == kFullAnimationLength ? 0.7f : 1.0f;

        [UIView addKeyframeWithRelativeStartTime:relativeStartTime relativeDuration:relativeDuration animations:^{
            self.cancelButton.frame = cancelButtonHiddenFrame();
            // use contentOffset for swiping tableView below the screen
            self.tableView.contentOffset = CGPointMake(0, -CGRectGetHeight(self.frame));
        }];
    } completion:^(BOOL finished) {
        if (completionHandler) {
            completionHandler(self);
        }
        [self.window removeFromSuperview];
        self.window = nil;

        [self.previousKeyWindow makeKeyAndVisible];
    }];
}

- (void)setUpBlurredBackgroundWithSnapshot:(UIImage *)previousKeyWindowSnapshot
{
    if (!self.blurredBackgroundView) {
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
}

- (void)cancelButtonTapped:(id)sender
{
    [self dismissAnimated:YES duration:kFullAnimationLength completion:self.cancelHandler];
}

- (void)setUpCancelButton
{
    if (!self.cancelButton) {
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
}

- (void)setUpTableView
{
    if (!self.tableView) {
        CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        CGRect frame = CGRectMake(0,
                                  statusBarHeight,
                                  CGRectGetWidth(self.frame),
                                  CGRectGetHeight(self.frame));
        self.tableView = [[UITableView alloc] initWithFrame:frame];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        [self insertSubview:self.tableView aboveSubview:self.blurredBackgroundView];
    }
}

- (void)fadeBlurOnScrollToTop
{
    if (self.tableView.isDragging || self.tableView.isDecelerating) {
        CGFloat alphaWithoutBounds = 1.0f - ( -(kTopInset + self.tableView.contentOffset.y) / kBlurFadeRangeSize);
        // limit alpha to the interval [0, 1]
        CGFloat alpha = MAX(MIN(alphaWithoutBounds, 1.0f), 0.0f);
        self.blurredBackgroundView.alpha = alpha;
    }
}

@end
