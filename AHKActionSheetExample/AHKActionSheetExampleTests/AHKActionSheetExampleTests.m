//
//  AHKActionSheetExampleTests.m
//  AHKActionSheetExampleTests
//
//  Created by Arkadiusz on 08-04-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AHKActionSheet.h"

@implementation UIView (Tests)
/// Check recursively if the view or one its subviews contains the view
- (BOOL)containsView:(UIView *)otherView
{
    for (UIView *subview in self.subviews) {
        if (subview == otherView || [subview containsView:otherView]) {
            return YES;
        }
    }

    return NO;
}
@end

@interface AHKActionSheetExampleTests : XCTestCase
@property (strong, nonatomic) AHKActionSheet *actionSheet;
@end

@implementation AHKActionSheetExampleTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    self.actionSheet = [[AHKActionSheet alloc] init];
    [self.actionSheet addButtonWithTitle:@"Test" type:AHKActionSheetButtonTypeDefault handler:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNoButtons
{
    AHKActionSheet *actionSheetWithoutButtons = [[AHKActionSheet alloc] init];
    XCTAssertThrows([actionSheetWithoutButtons show], @"Should fail an assertion.");
}

- (void)testWithButtons
{
    XCTAssertNoThrow([self.actionSheet show], @"Shouldn't fail an assertion.");
}

- (void)testPresentedInNewWindow
{
    XCTAssertFalse([[UIApplication sharedApplication].keyWindow containsView:self.actionSheet], @"Key window shouldn't contain the action sheet");

    [self.actionSheet show];

    XCTAssertTrue([[UIApplication sharedApplication].keyWindow containsView:self.actionSheet], @"Key window should contain the action sheet");
}

- (void)testCancelHandler
{
    __block BOOL cancelled = NO;
    self.actionSheet.cancelHandler = ^(AHKActionSheet *actionSheet){
        cancelled = YES;
    };

    [self.actionSheet show];
    [self.actionSheet dismissAnimated:NO];

    XCTAssertTrue(cancelled, @"`cancelled` should be true");
}

@end
