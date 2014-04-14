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

@property (nonatomic) CGFloat blurRadius UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *blurTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat blurSaturationDeltaFactor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat buttonHeight UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) AHKActionSheetHandler cancelHandler;
@property (weak, nonatomic, readonly) UIWindow *previousKeyWindow;

- (instancetype)initWithTitle:(NSString *)title;
- (void)addButtonWithTitle:(NSString *)title type:(AHKActionSheetButtonType)type handler:(AHKActionSheetHandler)handler;
- (void)show;
- (void)dismissAnimated:(BOOL)animated;

@end
