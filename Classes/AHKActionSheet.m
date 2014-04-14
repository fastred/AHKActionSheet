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
#import "UIImage+AHKAdditions.h"


@interface AHKActionSheetItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) AHKActionSheetButtonType type;
@property (strong, nonatomic) AHKActionSheetHandler handler;
@end

@implementation AHKActionSheetItem
@end


static CGFloat const kFullAnimationLength = 0.5f;
static CGFloat kBlurFadeRangeSize = 200.0f;
static NSString * const kCellIdentifier = @"Cell";


@interface AHKActionSheet() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *items;
@property (weak, nonatomic, readwrite) UIWindow *previousKeyWindow;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIImageView *blurredBackgroundView;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, getter = isVisible) BOOL visible;
@property (strong, nonatomic) UIButton *cancelButton;
@end

@implementation AHKActionSheet

#pragma mark - Init

+ (void)initialize
{
    if (self != [AHKActionSheet class]) {
        return;
    }

    AHKActionSheet *appearance = [self appearance];
    [appearance setBlurRadius:16.0f];
    [appearance setBlurTintColor:[UIColor colorWithWhite:1.0f alpha:0.25f]];
    [appearance setBlurSaturationDeltaFactor:1.8f];
    [appearance setButtonHeight:60.0f];
    [appearance setCancelButtonHeight:44.0f];
    [appearance setAutomaticallyTintButtonImages:@YES];
    [appearance setSelectedBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.2]];
    [appearance setCancelButtonTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                                                 NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    [appearance setButtonTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f]}];
    [appearance setDestructiveButtonTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                                                      NSForegroundColorAttributeName : [UIColor redColor] }];
    [appearance setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.0f],
                                                      NSForegroundColorAttributeName : [UIColor grayColor] }];
}

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];

    if (self) {
        _title = title;
        _cancelButtonTitle = @"Cancel";
    }

    return self;
}

- (instancetype)init
{
    return [self initWithTitle:nil];
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
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

    NSDictionary *attributes = item.type == AHKActionSheetButtonTypeDefault ? self.buttonTextAttributes : self.destructiveButtonTextAttributes;
    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:item.title attributes:attributes];
    cell.textLabel.attributedText = attrTitle;
    cell.textLabel.textAlignment = [self.buttonTextCenteringEnabled boolValue] ? NSTextAlignmentCenter : NSTextAlignmentLeft;

    // Use image with template mode with color the same as the text (when enabled).
    cell.imageView.image = [self.automaticallyTintButtonImages boolValue] ? [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : item.image;
    cell.imageView.tintColor = attributes[NSForegroundColorAttributeName] ? attributes[NSForegroundColorAttributeName] : [UIColor blackColor];

    cell.backgroundColor = [UIColor clearColor];

    if (self.selectedBackgroundColor && ![cell.selectedBackgroundView.backgroundColor isEqual:self.selectedBackgroundColor]) {
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;
    }

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

    BOOL viewWasFlickedDown = scrollVelocity.y > flickDownMinVelocity && scrollView.contentOffset.y < -self.tableView.contentInset.top - flickDownHandlingOffset;
    BOOL shouldSlideDown = scrollView.contentOffset.y < -self.tableView.contentInset.top - autoDismissOffset;
    if (viewWasFlickedDown) {
        // use shorter duration for a flick down animation
        CGFloat duration = 0.2f;
        [self dismissAnimated:YES duration:duration completion:self.cancelHandler];
    } else if (shouldSlideDown) {
        [self dismissAnimated:YES duration:kFullAnimationLength completion:self.cancelHandler];
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
    [self addButtonWithTitle:title image:nil type:type handler:handler];
}

- (void)addButtonWithTitle:(NSString *)title image:(UIImage *)image type:(AHKActionSheetButtonType)type handler:(AHKActionSheetHandler)handler
{
    AHKActionSheetItem *item = [[AHKActionSheetItem alloc] init];
    item.title = title;
    item.image = image;
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
    UIImage *previousKeyWindowSnapshot = [self.previousKeyWindow.rootViewController.view AHKsnapshotImage];

    [self setUpNewWindow];
    [self setUpBlurredBackgroundWithSnapshot:previousKeyWindowSnapshot];
    [self setUpCancelButton];
    [self setUpTableView];
    self.visible = YES;

    // Animate sliding in tableView and cancel button with keyframe animation for a nicer effect.
    [UIView animateKeyframesWithDuration:kFullAnimationLength delay:0 options:0 animations:^{
        self.blurredBackgroundView.alpha = 1.0f;

        [UIView addKeyframeWithRelativeStartTime:0.3f relativeDuration:0.7f animations:^{
            self.cancelButton.frame = CGRectMake(0,
                                                 CGRectGetMaxY(self.bounds) - self.cancelButtonHeight,
                                                 CGRectGetWidth(self.bounds),
                                                 self.cancelButtonHeight);

            static CGFloat topSpaceMarginPercentage = 0.333f;
            // manual calculation of table's contentSize.height
            CGFloat tableContentHeight = [self.items count] * self.buttonHeight + CGRectGetHeight(self.tableView.tableHeaderView.frame);

            CGFloat topInset;
            BOOL buttonsFitInWithoutScrolling = tableContentHeight < CGRectGetHeight(self.tableView.frame) * (1.0 - topSpaceMarginPercentage);
            if (buttonsFitInWithoutScrolling) {
                // show all buttons if there isn't many
                topInset = CGRectGetHeight(self.tableView.frame) - tableContentHeight;
            } else {
                // leave an empty space on the top to make the control look similar to UIActionSheet
                topInset = CGRectGetHeight(self.tableView.frame) * topSpaceMarginPercentage;
            }
            self.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
        }];
    } completion:nil];
}

- (void)dismissAnimated:(BOOL)animated
{
    [self dismissAnimated:animated duration:kFullAnimationLength completion:self.cancelHandler];
}

#pragma mark - Private

- (void)dismissAnimated:(BOOL)animated duration:(CGFloat)duration completion:(AHKActionSheetHandler)completionHandler
{
    // delegate isn't needed anymore because tableView will be hidden (and we don't want delegate methods to be called now)
    self.tableView.delegate = nil;
    self.tableView.userInteractionEnabled = NO;
    // keep the table from scrolling up
    self.tableView.contentInset = UIEdgeInsetsMake(-self.tableView.contentOffset.y, 0, 0, 0);

    void(^tearDownView)(void) = ^(void) {
        [self.window removeFromSuperview];
        self.window = nil;

        [self.previousKeyWindow makeKeyAndVisible];
        self.visible = NO;
        [self.tableView removeFromSuperview];
        [self.cancelButton removeFromSuperview];
        [self.blurredBackgroundView removeFromSuperview];
        self.tableView = nil;
        self.cancelButton = nil;
        self.blurredBackgroundView = nil;
        if (completionHandler) {
            completionHandler(self);
        }
    };

    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            self.blurredBackgroundView.alpha = 0.0f;
            self.cancelButton.transform = CGAffineTransformTranslate(self.cancelButton.transform, 0, self.cancelButtonHeight);

            // shortest change of position to hide all tableView contents below the bottom margin
            CGRect frameBelow = self.tableView.frame;
            CGFloat slideDownMinOffset = MIN(CGRectGetHeight(self.frame) + self.tableView.contentOffset.y, CGRectGetHeight(self.frame));
            frameBelow.origin = CGPointMake(0, slideDownMinOffset);
            self.tableView.frame = frameBelow;

        } completion:^(BOOL finished) {
            tearDownView();
        }];
    } else {
        tearDownView();
    }
}

- (void)setUpNewWindow
{
    AHKActionSheetViewController *actionSheetVC = [[AHKActionSheetViewController alloc] initWithNibName:nil bundle:nil];
    actionSheetVC.actionSheet = self;

    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.window.opaque = NO;
        self.window.rootViewController = actionSheetVC;
    }
    [self.window makeKeyAndVisible];
}

- (void)setUpBlurredBackgroundWithSnapshot:(UIImage *)previousKeyWindowSnapshot
{
    if (!self.blurredBackgroundView) {
        UIImage *blurredViewSnapshot = [previousKeyWindowSnapshot
                                        AHKapplyBlurWithRadius:self.blurRadius
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
        NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:self.cancelButtonTitle
                                                                        attributes:self.cancelButtonTextAttributes];
        [self.cancelButton setAttributedTitle:attrTitle forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton.frame = CGRectMake(0,
                                             CGRectGetMaxY(self.bounds) - self.cancelButtonHeight,
                                             CGRectGetWidth(self.bounds),
                                             self.cancelButtonHeight);
        self.cancelButton.transform = CGAffineTransformMakeTranslation(0, self.cancelButtonHeight);
        [self addSubview:self.cancelButton];
    }
}

- (void)setUpTableView
{
    if (!self.tableView) {
        CGRect statusBarViewRect = [self convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil];
        CGFloat statusBarHeight = CGRectGetHeight(statusBarViewRect);
        CGRect frame = CGRectMake(0,
                                  statusBarHeight,
                                  CGRectGetWidth(self.bounds),
                                  CGRectGetHeight(self.bounds) - statusBarHeight - self.cancelButtonHeight);
        self.tableView = [[UITableView alloc] initWithFrame:frame];

        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        if (self.separatorColor) {
            self.tableView.separatorColor = self.separatorColor;
        }

        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        [self insertSubview:self.tableView aboveSubview:self.blurredBackgroundView];
        self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.bounds), 0, 0, 0);

        [self setUpTableViewHeader];
    }
}

- (void)setUpTableViewHeader
{
    if (self.title) {
        static CGFloat leftRightPadding = 15.0f;
        static CGFloat topBottomPadding = 8.0f;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) - 2*leftRightPadding;

        NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:self.title attributes:self.titleTextAttributes];

        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        [label setAttributedText:attrText];
        CGSize labelSize = [label sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
        label.frame = CGRectMake(leftRightPadding, topBottomPadding, labelWidth, labelSize.height);

        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), labelSize.height + 2*topBottomPadding)];
        [headerView addSubview:label];
        self.tableView.tableHeaderView = headerView;

    } else if (self.headerView) {
        self.tableView.tableHeaderView = self.headerView;
    }

    // add a separator between the tableHeaderView and a first row
    if (self.tableView.tableHeaderView && self.tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
        static CGFloat separatorHeight = 0.5f;
        CGRect separatorFrame = CGRectMake(self.tableView.separatorInset.left,
                                           CGRectGetHeight(self.tableView.tableHeaderView.frame) - separatorHeight,
                                           CGRectGetWidth(self.tableView.tableHeaderView.frame) - (self.tableView.separatorInset.left + self.tableView.separatorInset.right),
                                           separatorHeight);
        UIView *separator = [[UIView alloc] initWithFrame:separatorFrame];
        separator.backgroundColor = self.tableView.separatorColor;
        [self.tableView.tableHeaderView addSubview:separator];
    }
}

- (void)fadeBlurOnScrollToTop
{
    if (self.tableView.isDragging || self.tableView.isDecelerating) {
        CGFloat alphaWithoutBounds = 1.0f - ( -(self.tableView.contentInset.top + self.tableView.contentOffset.y) / kBlurFadeRangeSize);
        // limit alpha to the interval [0, 1]
        CGFloat alpha = MAX(MIN(alphaWithoutBounds, 1.0f), 0.0f);
        self.blurredBackgroundView.alpha = alpha;
    }
}

@end
