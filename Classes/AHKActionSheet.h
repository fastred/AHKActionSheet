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

@interface AHKActionSheet : UIView

@property (nonatomic) CGFloat blurRadius;
@property (strong, nonatomic) UIColor *blurTintColor;
@property (nonatomic) CGFloat blurSaturationDeltaFactor;
@property (nonatomic) CGFloat topInset;
@property (strong, nonatomic) AHKActionSheetHandler cancelHandler;

- (instancetype)initWithTitle:(NSString *)title;
- (void)addButtonWithTitle:(NSString *)title type:(AHKActionSheetButtonType)type handler:(AHKActionSheetHandler)handler;
- (void)show;
- (void)dismissAnimated:(BOOL)animated;

@end
