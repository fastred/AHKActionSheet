//
//  UIView+Snapshots.m
//  AHKActionSheetExample
//
//  Created by Arkadiusz on 08-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import "UIView+Snapshots.h"

@implementation UIView (Snapshots)

- (UIImage *)AHKsnapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0.0f);
    [self drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return snapshot;
}

@end
