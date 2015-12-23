//
//  AHKActionSheetItem.h
//  AHKActionSheetExample
//
//  Created by Muhammad Fahied on 12/23/15.
//  Copyright (c) 2015 Arkadiusz Holko. All rights reserved.
//

@import Foundation;
@class AHKActionSheetItem;


typedef NS_ENUM(NSInteger, AHKActionSheetButtonType) {
    AHKActionSheetButtonTypeDefault = 0,
    AHKActionSheetButtonTypeDisabled,
    AHKActionSheetButtonTypeDestructive
};

typedef void(^AHKActionSheetHandler)(AHKActionSheetItem *actionSheetItem);


@interface AHKActionSheetItem : NSObject

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) AHKActionSheetButtonType type;
@property (strong, nonatomic) AHKActionSheetHandler handler;

@end
