//
//  AHKActionSheet.h
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 08-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AHKActionSheetButtonType) {
    AHKActionSheetButtonTypeDefault = 0,
    AHKActionSheetButtonTypeDestructive
};

@class AHKActionSheet;
typedef void(^AHKActionSheetHandler)(AHKActionSheet *actionSheet);


@interface AHKActionSheet : UIView <UIAppearanceContainer>

// Appearance - all of the following properties should be set before showing the action sheet.

/**
 *  See UIImage+AHKAdditions.h/.m to learn how these three properties are used.
 */
@property (nonatomic) CGFloat blurRadius UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *blurTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat blurSaturationDeltaFactor UI_APPEARANCE_SELECTOR;

/// Height of the button (internally it's a UITableViewCell).
@property (nonatomic) CGFloat buttonHeight UI_APPEARANCE_SELECTOR;
/// Height of the cancel button (internally it's a UIButton).
@property (nonatomic) CGFloat cancelButtonHeight UI_APPEARANCE_SELECTOR;
/**
 *  If set, a small shadow (a gradient layer) will be drawn above the cancel button to separate it visually from the other buttons.
 * It's best to use a color similar (but maybe with a lower alpha value) to blurTintColor.
 * See "Advanced" example in the example project to see it used.
 */
@property (strong, nonatomic) UIColor *cancelButtonShadowColor UI_APPEARANCE_SELECTOR;
/// Boxed (@YES, @NO) boolean value (enabled by default)
@property (strong, nonatomic) NSNumber *automaticallyTintButtonImages UI_APPEARANCE_SELECTOR;
/// Boxed boolean value. Useful when adding buttons without images (in that case text looks better centered). Disabled by default.
@property (strong, nonatomic) NSNumber *buttonTextCenteringEnabled UI_APPEARANCE_SELECTOR;
/// Color of the separator between buttons.
@property (strong, nonatomic) UIColor *separatorColor UI_APPEARANCE_SELECTOR;
/// Background color of the button when it's tapped (internally it's a UITableViewCell)
@property (strong, nonatomic) UIColor *selectedBackgroundColor UI_APPEARANCE_SELECTOR;
/// Text attributes of the title (passed in initWithTitle: or set via `title` property)
@property (copy, nonatomic) NSDictionary *titleTextAttributes UI_APPEARANCE_SELECTOR;
@property (copy, nonatomic) NSDictionary *buttonTextAttributes UI_APPEARANCE_SELECTOR;
@property (copy, nonatomic) NSDictionary *destructiveButtonTextAttributes UI_APPEARANCE_SELECTOR;
@property (copy, nonatomic) NSDictionary *cancelButtonTextAttributes UI_APPEARANCE_SELECTOR;


/// Called on every type of dismissal (tapping on "Cancel" or swipe down or flick down).
@property (strong, nonatomic) AHKActionSheetHandler cancelHandler;
@property (copy, nonatomic) NSString *cancelButtonTitle;
/// Action sheet title shown above the buttons.
@property (copy, nonatomic) NSString *title;
/// View shown above the buttons (only if the title isn't set).
@property (strong, nonatomic) UIView *headerView;
/// Window visible before the actionSheet was presented.
@property (weak, nonatomic, readonly) UIWindow *previousKeyWindow;


// Designated initializer.
- (instancetype)initWithTitle:(NSString *)title;
// Add a button without an image. Has to be called before showing the action sheet.
- (void)addButtonWithTitle:(NSString *)title type:(AHKActionSheetButtonType)type handler:(AHKActionSheetHandler)handler;
// As above but with an image. Has to be called before showing the action sheet.
- (void)addButtonWithTitle:(NSString *)title image:(UIImage *)image type:(AHKActionSheetButtonType)type handler:(AHKActionSheetHandler)handler;
- (void)show;
- (void)dismissAnimated:(BOOL)animated;

@end
