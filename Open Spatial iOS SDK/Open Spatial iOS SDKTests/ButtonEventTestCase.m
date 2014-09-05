//
//  ButtonEventTestCase.m
//  Open Spatial iOS SDK
//
//  Created by Khwaab Dave on 7/16/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OpenSpatialDecoder.h"
#import "OpenSpatialBluetooth.h"
#import "ButtonEvent.h"
#import "PointerEvent.h"
#import "OpenSpatialTestDelegate.h"

@interface ButtonEventTestCase : XCTestCase

@property CBMutableCharacteristic *testCharacteristic;
@property OpenSpatialBluetooth *testBluetooth;
@property OpenSpatialTestDelegate *testDelegate;


@end

@implementation ButtonEventTestCase

- (void)setUp {
    [super setUp];
    CBUUID *characteristicOpenSpatial2DUUID = [CBUUID UUIDWithString:BUTTON_UUID];
    self.testCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicOpenSpatial2DUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];

    self.testBluetooth = [[OpenSpatialBluetooth alloc] init];
    self.testDelegate =  [[OpenSpatialTestDelegate alloc] init];
    self.testBluetooth.delegate  = self.testDelegate;

}

- (void)tearDown {
    self.testCharacteristic = nil;
    self.testBluetooth = nil;
    [super tearDown];}

- (void)testAllDown
{
    NSDictionary* buttonDic = @{TOUCH_0 : @BUTTON_DOWN,
                                TOUCH_1 : @BUTTON_DOWN,
                                TOUCH_2: @BUTTON_DOWN,
                                TACTILE_0 : @BUTTON_DOWN,
                                TACTILE_1 : @BUTTON_DOWN};

    const char* openSpatial2DPointer  = [OpenSpatialDecoder createButtonPointer:buttonDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:BUTTON_SIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];

    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:0] getButtonEventType], TOUCH0_DOWN, @"The Touch 0 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:1] getButtonEventType], TOUCH1_DOWN, @"The Touch 1 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:2] getButtonEventType], TOUCH2_DOWN, @"The Touch 2 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:3] getButtonEventType], TACTILE0_DOWN, @"The Tact 0 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:4] getButtonEventType], TACTILE1_DOWN, @"The Tact 1 value did not match");
    
}

- (void)testAllUp
{
    NSDictionary* buttonDic = @{TOUCH_0 : @BUTTON_UP,
                                TOUCH_1 : @BUTTON_UP,
                                TOUCH_2: @BUTTON_UP,
                                TACTILE_0 : @BUTTON_UP,
                                TACTILE_1 : @BUTTON_UP};

    const char* openSpatial2DPointer  = [OpenSpatialDecoder createButtonPointer:buttonDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:BUTTON_SIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];

    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:0] getButtonEventType], TOUCH0_UP, @"The Touch 0 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:1] getButtonEventType], TOUCH1_UP, @"The Touch 1 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:2] getButtonEventType], TOUCH2_UP, @"The Touch 2 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:3] getButtonEventType], TACTILE0_UP, @"The Tact 0 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:4] getButtonEventType], TACTILE1_UP, @"The Tact 1 value did not match");
    
}

- (void)testRandom
{
    NSDictionary* buttonDic = @{TOUCH_0 : @BUTTON_UP,
                                TOUCH_1 : @BUTTON_DOWN,
                                TOUCH_2: @BUTTON_UNUSED,
                                TACTILE_0 : @BUTTON_DOWN,
                                TACTILE_1 : @BUTTON_UNUSED};

    const char* openSpatial2DPointer  = [OpenSpatialDecoder createButtonPointer:buttonDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:BUTTON_SIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];

    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:0] getButtonEventType], TOUCH0_UP, @"The Touch 0 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:1] getButtonEventType], TOUCH1_DOWN, @"The Touch 1 value did not match");
    XCTAssertEqual([[openSpatial2DEvents objectAtIndex:2] getButtonEventType], TACTILE0_DOWN, @"The Tact 0 value did not match");

}


@end
